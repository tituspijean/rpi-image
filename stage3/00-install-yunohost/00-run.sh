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

install -m 755 files/check_yunohost_is_installed.sh "${ROOTFS_DIR}/etc/profile.d/"

echo "Cleaning ..."
on_chroot << EOF
apt-get clean
find /var/log -type f -exec rm {} \;
ps -ef --forest | grep qemu
EOF

# Gotta manually kill those stuff which are some sort of daemon running
# for slapd / nscd / nslcd ... otherwise the script is unable to unmount
# the rootfs/image after that ?
for PID in `ps -ef --forest | grep "qemu-arm-static" | grep "nginx\|nscd\|slapd\|nslcd" | awk '{print $2}'`
do
        echo "Killing $PID"
        kill -9 $PID
done
