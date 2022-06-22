#!/bin/bash -e
TARGET_ROOTFS_DIR="binary"
ARCH=arm64

echo "in mk-adv.sh"


#-----------------Overlay------------------
echo "1.copy overlay"
sudo cp -rf overlay-adv/* $TARGET_ROOTFS_DIR/
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
apt-get install -y gnome-screenshot
apt-get install -y mtd-utils
apt-get install -y i2c-tools
apt-get install -y minicom
apt-get install -y ethtool
apt-get install -y pciutils
apt-get install -y hdparm
apt-get install -y ftp
#for rpmb
apt-get install -y mmc-utils
#for 4G
apt-get install -y libpcap0.8 ppp
apt-get install -y usb-modeswitch mobile-broadband-provider-info modemmanager

#for bt udev
apt-get install -y at
apt-get install -y bluez-hcidump

#for camera
apt-get install -y v4l-utils
apt-get install -y guvcview

# for mosquitto
apt-get install -y mosquitto mosquitto-dev libmosquitto-dev

#for sync time
apt-get remove --purge -y cron
if [ -f /etc/crontab ]; then
	rm -rf /etc/crontab
fi
apt-get install -y cron
/tmp/timesync.sh
rm -rf /tmp/timesync.sh

# For logrotate limit log size
apt-get install -y logrotate

#for docker
dpkg -i packages/docker/*.deb
apt-get install -f -y


#-----------------Adjust------------------
systemctl enable advinit.service

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

#mount userdata to /userdata
rm /userdata /oem /misc -rf
mkdir /userdata
mkdir /oem
chmod 0777 /userdata
chmod 0777 /oem

ln -s /dev/disk/by-partlabel/misc /misc

# for MPV
#chown -R linaro:linaro /home/linaro/.config


#-----------------Clean------------------
sudo apt-get clean
rm -rf /var/lib/apt/lists/*
rm -rf packages/rga/
rm -rf packages/gst-rkmpp/
rm -rf packages/gstreamer/
rm -rf packages/gst-plugins-base1.0/
rm -rf packages/gst-plugins-bad1.0/
rm -rf packages/gst-plugins-good1.0/
rm -rf packages/ffmpeg/
rm -rf packages/mpv/
rm -rf packages/rkaiq/
rm -rf packages/libv4l/
rm -rf packages/xserver/
rm -rf packages/openbox/
rm -rf packages/chromium/
rm -rf packages/libdrm/
rm -rf packages/libdrm-cursor/
rm -rf packages/pcmanfm/
rm -rf packages/blueman/
rm -rf packages/rkwifibt/
rm -rf packages/glmark2/
rm -rf packages/rktoolkit/
rm -rf packages/docker/


EOF

sudo umount $TARGET_ROOTFS_DIR/dev


