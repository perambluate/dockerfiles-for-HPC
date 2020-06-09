#!/bin/bash

#prerequisite
apt update && apt autoremove libnccl* &&\
apt install -y build-essential devscripts debhelper fakeroot git

#install from nccl github
git clone https://github.com/NVIDIA/nccl.git &&\
cd nccl && make pkg.debian.build -j$(nproc) && dpkg -i build/pkg/deb/libnccl*
