#!/bin/bash -e
VERSION=2.4.110
sudo apt-get build-dep -y libdrm
sudo apt-get build-dep -y -a armhf libdrm
sudo apt-get install -y python3-setuptools
cd /home/rockchip/sdk/external/libdrm-rockchip/
dpkg-buildpackage -us -uc --host-arch=armhf -b
mv /home/rockchip/sdk/external/libdrm*$VERSION*armhf*.deb /home/rockchip/sdk/debian/packages/armhf/libdrm/
mv /home/rockchip/sdk/external/libdrm*$VERSION*all*.deb /home/rockchip/sdk/debian/packages/armhf/libdrm/