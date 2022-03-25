#!/bin/bash -e

if [ -f $TOP_DIR/buildroot/output/.config ];then
    source $TOP_DIR/buildroot/output/.config
    BT_TTY=$BR2_PACKAGE_RKWIFIBT_BTUART
    BT_FW=$BR2_PACKAGE_RKWIFIBT_BT_FW
    WIFI_KO=$BR2_PACKAGE_RKWIFIBT_WIFI_KO
else
    BT_TTY="ttyS8"
    BT_FW="BCM4362A2.hcd"
    WIFI_KO="bcmdhd.ko"
fi

install -v -m 0755 files/rkwifi.service $ROOTFS_DIR/etc/systemd/system/  
mkdir -p $ROOTFS_DIR/system/lib/modules/ $ROOTFS_DIR/vendor/etc $ROOTFS_DIR/system/lib/modules 
mkdir -p $ROOTFS_DIR/system/etc/firmware $ROOTFS_DIR/usr/lib/modules $ROOTFS_DIR/lib/firmware/rtlbt
find $TOP_DIR/kernel/drivers/net/wireless/rockchip_wlan/* -name $WIFI_KO | xargs -n1 -i cp {} $ROOTFS_DIR/system/lib/modules/

on_chroot <<EOF
    systemctl enable rkwifi
    ln -sf /system/etc/firmware /vendor/etc/
    apt-get install -fy --allow-downgrades /sdk/debian/packages/${ARCH}/rkwifibt/rkwifibt-dev-tools*.deb
EOF

install -v -m 0755 $TOP_DIR/external/rkwifibt/wpa_supplicant.conf $ROOTFS_DIR/etc/
install -v -m 0755 $TOP_DIR/external/rkwifibt/dnsmasq.conf $ROOTFS_DIR/etc/
install -v -m 0755 $TOP_DIR/external/rkwifibt/wifi_start.sh $ROOTFS_DIR/usr/bin/
install -v -m 0755 $TOP_DIR/external/rkwifibt//wifi_ap6xxx_rftest.sh $ROOTFS_DIR/usr/bin/
install -v -m 0755 $TOP_DIR/external/rkwifibt/S36load_wifi_modules $ROOTFS_DIR/etc/init.d/
sed -i "s/WIFI_KO/\/system\/lib\/modules\/$WIFI_KO/g" $ROOTFS_DIR/etc/init.d/S36load_wifi_modules
sed -i "s/BT_TTY_DEV/\/dev\/$BT_TTY/g" $ROOTFS_DIR/etc/init.d/S36load_wifi_modules

install -v -m 0644 $TOP_DIR/external/rkwifibt/firmware/broadcom/all/wifi/* $ROOTFS_DIR/system/etc/firmware/
if [ "${ARCH}" == "armhf" ]; then
    install -v -m 0755 $TOP_DIR/external/rkwifibt/bin/arm/* $ROOTFS_DIR/usr/bin/
else
    install -v -m 0755 $TOP_DIR/external/rkwifibt/bin/arm64/* $ROOTFS_DIR/usr/bin/
fi
install -v -m 0644 $TOP_DIR/external/rkwifibt/firmware/broadcom/all/bt/* $ROOTFS_DIR/system/etc/firmware/
install -v -m 0755 $TOP_DIR/external/rkwifibt/bt_load_broadcom_firmware $ROOTFS_DIR/usr/bin/
sed -i "s/BTFIRMWARE_PATH/\/system\/etc\/firmware\/$BT_FW/g" $ROOTFS_DIR/usr/bin/bt_load_broadcom_firmware
sed -i "s/BT_TTY_DEV/\/dev\/$BT_TTY/g" $ROOTFS_DIR/usr/bin/bt_load_broadcom_firmware
install -v -m 0755 $ROOTFS_DIR/usr/bin/bt_load_broadcom_firmware $ROOTFS_DIR/usr/bin/bt_pcba_test
install -v -m 0755 $ROOTFS_DIR/usr/bin/bt_load_broadcom_firmware $ROOTFS_DIR/usr/bin/bt_init.sh



