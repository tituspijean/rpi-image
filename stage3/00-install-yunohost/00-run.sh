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
