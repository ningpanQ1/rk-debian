#!/bin/bash -e
TARGET_ROOTFS_DIR="binary"
RELEASE_VERSION="2.0.0.4"
ARCH=arm64

echo "in mk-adv.sh"


#-----------------Overlay------------------
echo "1.copy overlay"
sudo cp -dprf overlay-adv/* $TARGET_ROOTFS_DIR/
sudo cp -rf packages-adv/$ARCH/* $TARGET_ROOTFS_DIR/packages/

sudo cp -rf adv-build/* $TARGET_ROOTFS_DIR/tmp/


echo "2.install/remove/adjust debian"

finish() {
	sudo umount $TARGET_ROOTFS_DIR/dev
	exit -1
}
trap finish ERR


sudo mount -o bind /dev $TARGET_ROOTFS_DIR/dev

cat << EOF | sudo chroot $TARGET_ROOTFS_DIR

#-----------------Remove-------------------


#-----------------Install------------------
apt-get update
#apt-get install -y gnome-screenshot
apt-get install -y mtd-utils
apt-get install -y minicom
apt-get install -y ethtool
apt-get install -y iperf3
apt-get install -y hdparm
apt-get install -y ftp
apt-get install -y xfce4-terminal
apt-get install -y xfce4-screenshooter
#for rpmb
apt-get install -y mmc-utils
#for 4G
apt-get install -y usb-modeswitch mobile-broadband-provider-info modemmanager

#for bt udev
apt-get install -y at
apt-get install -y bluez-hcidump

#for camera
apt-get install -y guvcview

# for mosquitto
apt-get install -y mosquitto mosquitto-dev libmosquitto-dev

#for calibrator
#apt-get install -y xinput
#apt-get install -y xinput-calibrator

#for onboard
apt-get install -y onboard
sed -i 's/OnlyShowIn=Unity;MATE;/OnlyShowIn=Unity;MATE;xfce;/g' /etc/xdg/autostart/onboard-autostart.desktop

#for sync time
apt-get install -y cron
/tmp/timesync.sh
rm -rf /tmp/timesync.sh

# For logrotate limit log size
apt-get install -y logrotate

#for docker
dpkg -i packages/docker/*.deb
apt-get install -f -y

#for florence
dpkg -i packages/florence/*.deb

#for udisk2
apt-get install -y libblockdev-crypto2
apt-get install -y libblockdev-mdraid2

#for udiskie
apt-get install -y udiskie
apt-get install -y gir1.2-notify-0.7
apt-get install -y gobject-introspection
apt-get install -y python3-keyutils

#for fix udiskie debug error
apt-get install -y appmenu-gtk2-module appmenu-gtk3-module
apt-get install -y at-spi2-core

#for screen locker
apt-get install -y xscreensaver
apt-get install -y light-locker
apt-get install -y mate-screensaver
apt-get install -y gnome-screensaver
#-----------------Adjust------------------
systemctl enable advinit.service
systemctl enable adv_service_detect.service
sudo update-alternatives --set iptables /usr/sbin/iptables-legacy
sudo update-alternatives --set ip6tables /usr/sbin/ip6tables-legacy

#for login
echo "linaro:123456" | chpasswd
echo "root:123456" | chpasswd

#locale
sed -i 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/g' /etc/locale.gen
sed -i 's/# zh_CN GB2312/zh_CN GB2312/g' /etc/locale.gen
sed -i 's/# zh_CN.GB18030 GB18030/zh_CN.GB18030 GB18030/g' /etc/locale.gen
sed -i 's/# zh_CN.GBK GBK/zh_CN.GBK GBK/g' /etc/locale.gen
sed -i 's/# zh_CN.UTF-8 UTF-8/zh_CN.UTF-8 UTF-8/g' /etc/locale.gen
sed -i 's/# zh_TW BIG5/zh_TW BIG5/g' /etc/locale.gen
sed -i 's/# zh_TW.EUC-TW EUC-TW/zh_TW.EUC-TW EUC-TW/g' /etc/locale.gen
sed -i 's/# zh_TW.UTF-8 UTF-8/zh_TW.UTF-8 UTF-8/g' /etc/locale.gen
locale-gen

#timezone
ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
echo "Asia/Shanghai" > /etc/timezone

#resolv.conf
ln -sf /run/resolvconf/resolv.conf /etc/resolv.conf

#mount userdata to /userdata
rm /userdata /oem /misc -rf
mkdir /userdata
mkdir /oem
chmod 0777 /userdata
chmod 0777 /oem

ln -s /dev/disk/by-partlabel/misc /misc

# for MPV
#chown -R linaro:linaro /home/linaro/.config

#chown linaro:linaro
#chown -R linaro:linaro /home/linaro/

#for linaro
echo "export PATH=$PATH:/sbin" >> /home/linaro/.bashrc

#Adding advantech-info to /etc/os-release...
echo "ADVANTECH_INFO=\"Beta release version:${RELEASE_VERSION}\"" >> /etc/os-release
#-----------------Clean------------------
sudo apt-get clean
rm -rf /var/lib/apt/lists/*
rm -rf /packages/

EOF

sudo umount $TARGET_ROOTFS_DIR/dev


