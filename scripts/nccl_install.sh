#!/bin/bash
NCCL_DIR=/opt/nccl
#prerequisite
apt update && apt autoremove libnccl* &&\
apt install -y build-essential devscripts debhelper fakeroot git

#install from nccl github
git clone https://github.com/NVIDIA/nccl.git ${NCCL_DIR} &&\
cd ${NCCL_DIR} && \
make pkg.debian.build -j$(nproc) && \
dpkg -i build/pkg/deb/libnccl*
