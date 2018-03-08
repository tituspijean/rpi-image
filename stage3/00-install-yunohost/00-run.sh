#!/bin/bash -e

on_chroot << EOF
cd /tmp/
wget -O install_yunohost https://install.yunohost.org/stretch
chmod +x /tmp/install_yunohost
./install_yunohost -a -i
EOF
