#!/bin/bash -e

# Avahi and mysql/mariadb needs to do some stuff which conflicts with
# the "change the root password asap" so we disable it. In fact, now
# that YunoHost 3.3 syncs the password with admin password at
# postinstall we are happy with not triggering a password change at
# first boot.  Assuming that ARM-boards won't be exposed to global
# network right after booting the first time ...
on_chroot << EOF
chage -d 99999999 root
EOF

# Run the actual install
on_chroot << EOF
apt-get install insserv resolvconf -y
curl https://install.yunohost.org/stretch | bash -s -- -a
rm -f /etc/ssh/ssh_host_*
EOF

echo "Enabling ssh login for root + setting default password"
on_chroot << EOF
touch /boot/ssh
sed -i '/PermitRootLogin/c\PermitRootLogin yes' /etc/ssh/sshd_config
echo "root:yunohost" | chpasswd
EOF

install -m 755 files/check_yunohost_is_installed.sh "${ROOTFS_DIR}/etc/profile.d/"

echo "Cleaning ..."
on_chroot << EOF
apt-get clean
find /var/log -type f -exec rm {} \;
EOF

# Gotta manually kill those stuff which are some sort of daemon running
# for slapd / nscd / nslcd ... otherwise the script is unable to unmount
# the rootfs/image after that ?
while lsof 2>/dev/null | grep -q /root/rpi-image/work/*/export-image/rootfs/dev;
do
    for PID in `ps -ef --forest | grep "qemu-arm-static" | grep -v "grep" | grep "nginx\|nscd\|slapd\|nslcd" | awk '{print $2}'`
    do
        echo "Killing $PID"
        kill -9 $PID || true
        sleep 1
    done
    sleep 5
done
while ps -ef --forest | grep "qemu-arm-static" | grep -v "grep"
do
    for PID in `ps -ef --forest | grep "qemu-arm-static" | grep -v "grep" | grep "nginx\|nscd\|slapd\|nslcd" | awk '{print $2}'`
    do
        echo "Killing $PID"
        kill -9 $PID || true
        sleep 1
    done
    sleep 5
done
