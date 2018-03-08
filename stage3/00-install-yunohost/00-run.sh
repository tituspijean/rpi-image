#!/bin/bash -e

install -m 744 files/install_yunohost ${ROOTFS_DIR}/tmp/

on_chroot << EOF
cd /tmp/
./install_yunohost -a -i
EOF
