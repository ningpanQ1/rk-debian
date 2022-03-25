#!/bin/bash -e

ARCH=armhf
VERSION=bullseye

SCRIPT_DIR=$(dirname $(realpath "$0"))
TOP_DIR=$(realpath "$SCRIPT_DIR/../..")
if [ $VERSION = bullseye ];then
    DOCKFILE=$SCRIPT_DIR/dockerfile_bullseye
elif [ $VERSION = bookworm ];then
    DOCKFILE=$SCRIPT_DIR/dockerfile_bookworm
elif [ $VERSION = sid ];then
    DOCKFILE=$SCRIPT_DIR/dockerfile_sid
fi

sudo mkdir -p /etc/docker
sudo tee /etc/docker/daemon.json <<-'EOF'
{
    "registry-mirrors": [
        "https://1nj0zren.mirror.aliyuncs.com",
        "https://2lqq34jg.mirror.aliyuncs.com",
        "https://hub-mirror.c.163.com",
        "https://mirror.ccs.tencentyun.com",
        "https://reg-mirror.qiniu.com",
        "https://docker.mirrors.ustc.edu.cn",
        "https://dockerhub.azk8s.cn",
        "http://f1361db2.m.daocloud.io"
    ]
}
EOF

sudo systemctl daemon-reload
sudo systemctl restart docker
sudo docker pull debian:$VERSION
sudo docker build --build-arg ARCH=$ARCH --build-arg VERSION=$VERSION --force-rm -t rockbian:$VERSION -< $DOCKFILE
sudo docker run -it -v $TOP_DIR:/home/rockchip/sdk rockbian:$VERSION /bin/bash