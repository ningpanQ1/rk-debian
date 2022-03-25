#!/bin/bash -ex

install -v -m 0644 $TOP_DIR/external/alsa-config/alsa/cards/* $ROOTFS_DIR/usr/share/alsa/cards/
install -v -m 0644 $TOP_DIR/external/alsa-config/alsa/init/* $ROOTFS_DIR/usr/share/alsa/init/
install -v -m 0644 -d $TOP_DIR/external/alsa-config/alsa/ucm/* $ROOTFS_DIR/usr/share/alsa/ucm/
install -v -m 0644 -d $TOP_DIR/debian/overlay/usr/share/alsa/ucm2/rockchip* $ROOTFS_DIR/usr/share/alsa/ucm2/
install -v -m 0644 $TOP_DIR/debian/overlay/usr/share/alsa/ucm2/ucm.conf $ROOTFS_DIR/usr/share/alsa/ucm2/