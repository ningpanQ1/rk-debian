#!/bin/bash -e

on_chroot <<EOF
    dpkg -i /sdk/debian/packages/${ARCH}/libdrm/*
    apt-get install -f
    apt-mark hold libdrm2 libdrm2-dbgsym libdrm-dev libdrm-common libdrm-tests libdrm-tests-dbgsym libdrm-libkms1
EOF

