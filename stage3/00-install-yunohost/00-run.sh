#!/bin/bash -e

on_chroot << EOF
cd /tmp/
wget -O install_yunohost https://install.yunohost.org/stretch
chmod +x /tmp/install_yunohost
./install_yunohost -a
rm -f /etc/ssh/ssh_host_*
apt-get clean
find /var/log -type f -exec rm {} \;
EOF
