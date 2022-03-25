#!/bin/bash -e

DEVICE_PATH=`realpath $TOP_DIR/device/rockchip/.target_product`
CHIP_NAME=`basename $DEVICE_PATH`
install -v -m 0755 -D $TOP_DIR/external/rkscript/glmarktest.sh $ROOTFS_DIR/usr/bin/
case $CHIP_NAME in
    rk3288)
        MALI=midgard-t76x-r18p0-r0p0
        # 3288w
        cat /sys/devices/platform/*gpu/gpuinfo | grep -q r1p0 && \
            MALI=midgard-t76x-r18p0-r1p0
        ;;
    rk3399|rk3399pro)
        MALI=midgard-t86x-r18p0
        ;;
    rk3328)
        MALI=utgard-450
        ;;
    rk3326|px30)
        MALI=bifrost-g31-g2p0
        ;;
    rk3128|rk3036)
        MALI=utgard-400
        ;;
    rk3568|rk3566)
        MALI=bifrost-g52-g2p0
        ;;
    rk3588|rk3588s)
        MALI=valhall-g610-g6p0
        ;;
esac

# on_chroot <<EOF
#     dpkg -i /sdk/debian/packages/${ARCH}/libmali/libmali-*$MALI*-x11*.deb
# EOF


