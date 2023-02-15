#!/bin/bash -e

TOP_DIR=`pwd`
DEBIAN_DIR="debian"

# make debian base
if [ "$1" == "new" ];then
	echo "make debian base new"
	cd $TOP_DIR/$DEBIAN_DIR
	RELEASE=bullseye TARGET=desktop ARCH=arm64 ./mk-base-debian.sh
else
	echo "use exist debian base"
	cat $DEBIAN_DIR/debian-base/linaro-bullseye-alip-*.tar.gz* > $DEBIAN_DIR/linaro-bullseye-alip-whole.tar.gz
fi

#make rockchip
cd $TOP_DIR/$DEBIAN_DIR
ARCH=arm64 ./mk-rootfs-bullseye.sh

# make advantech
./mk-adv.sh

# make image
./mk-image.sh
