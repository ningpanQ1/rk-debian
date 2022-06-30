#!/bin/bash -e

TOP_DIR=`pwd`


# make debian base
if [ "$1" == "new" ];then
	echo "make debian base new"
	RELEASE=bullseye TARGET=desktop ARCH=arm64 ./mk-base-debian.sh
else
	echo "use exist debian base"
	cat debian-base/linaro-bullseye-alip-*.tar.gz* > linaro-bullseye-alip-whole.tar.gz
fi

#make rockchip
ARCH=arm64 ./mk-rootfs-bullseye.sh

# make advantech
./mk-adv.sh

# make image
./mk-image.sh
