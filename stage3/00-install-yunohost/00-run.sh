#!/bin/bash -e

on_chroot << EOF
apt-get install insserv -y
cd /tmp/
wget -O install_yunohost https://install.yunohost.org/stretch
chmod +x /tmp/install_yunohost
./install_yunohost -a
rm -f /etc/ssh/ssh_host_*
EOF

echo "Enabling ssh login for root + setting default password"
on_chroot << EOF
touch /boot/ssh
sed -i '/PermitRootLogin/c\PermitRootLogin yes' /etc/ssh/sshd_config
echo "root:yunohost" | chpasswd
chage -d 0 root
EOF

echo "Cleaning ..."
on_chroot << EOF
apt-get clean
find /var/log -type f -exec rm {} \;
EOF

# Gotta manually kill those stuff which are some sort of daemon running
# for slapd / nscd / nslcd ... otherwise the script is unable to unmount
# the rootfs/image after that ?
for PID in `ps -ef --forest | awk '$8=="/usr/bin/qemu-arm-static" {print $2}'`
do
        kill -9 $PID
done
