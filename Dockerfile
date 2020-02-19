FROM ubuntu:18.04 
MAINTAINER perambluate 

# arguments
#ARG HOME=/home/t2
ARG MPIDIR=/opt
ARG APPDIR=/root
ARG DEBIAN_FRONTEND=noninteractive

# apt
RUN apt update -y && \
	apt install -y --reinstall systemd iptables && \
	apt install -y \
	gcc \
	g++ \
	make \
	wget \
	git \
	python3 \
	libatlas3-base \
	vim \
	locate \
	ssh \
	net-tools \
	iputils-ping \
	iproute2 \
	curl \
	environment-modules \
	cmake \
	libnss3 \
	libgtk2.*common \
	libpango-1* \
	libasound2* \
	xserver-xorg \
	cpio \
	libgtk-3-dev \
	libssl-dev \
	linux-headers-$(uname -r) \
	bash-completion \
	tcl \
	tmux

#openmpi	
#WORKDIR ${HOME}
#COPY openmpi-3.1.4 ${APPDIR}/openmpi

RUN	cd ${MPIDIR} && \
	wget https://download.open-mpi.org/release/open-mpi/v3.1/openmpi-3.1.4.tar.gz && \
	tar -zxvf openmpi-3.1.4.tar.gz && \
	rm openmpi-3.1.4.tar.gz && \
	cd openmpi-3.1.4 && \
	./configure --prefix=${MPIDIR}/openmpi && \
	make -j$(nproc) && \
	make install -j$(nproc) 

#intel mpi
#WORKDIR /opt
#COPY intel ${APPDIR}/intel
RUN cd ${MPIDIR} && \
	wget http://registrationcenter-download.intel.com/akdlm/irc_nas/tec/16225/parallel_studio_xe_2020_cluster_edition.tgz && \
	tar zxvf parallel_studio_xe_2020_cluster_edition.tgz && \
	rm parallel_studio_xe_2020_cluster_edition.tgz

# hpl-2.3
RUN cd ${APPDIR} && \
	wget https://www.netlib.org/benchmark/hpl/hpl-2.3.tar.gz && \
	tar -zxvf hpl-2.3.tar.gz && \
	rm hpl-2.3.tar.gz

# hpcg-3.1
RUN cd ${APPDIR} && \
	wget http://www.hpcg-benchmark.org/downloads/hpcg-3.1.tar.gz && \
	tar -zxvf hpcg-3.1.tar.gz && \
	rm hpcg-3.1.tar.gz && \
	mkdir hpcg-3.1/build

# hpcc-1.5.0
RUN cd ${APPDIR} && \
	wget http://icl.cs.utk.edu/projectsfiles/hpcc/download/hpcc-1.5.0.tar.gz && \
	tar -zxvf hpcc-1.5.0.tar.gz && \
	rm hpcc-1.5.0.tar.gz

# elmer/ice
RUN cd ${APPDIR} && \
	git clone https://github.com/ElmerCSC/elmerfem.git

# changa
RUN cd ${APPDIR} && \
	git clone http://charm.cs.illinois.edu/gerrit/cosmo/changa.git && \
	git clone http://charm.cs.illinois.edu/gerrit/cosmo/utility.git && \
	git clone http://charm.cs.uiuc.edu/gerrit/charm.git

# module file
COPY ./modulefiles ${APPDIR}/modulefiles
RUN source /etc/profile.d/modules.sh && \
	module use ${APPDIR}/modulefiles