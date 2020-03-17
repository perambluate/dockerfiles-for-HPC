FROM nvidia/cuda:10.0-devel-ubuntu18.04
MAINTAINER perambluate 

# arguments
#ARG HOME=/home/t2
ARG MPIDIR=/opt
ARG APPDIR=/root
ARG HOST_MPI_DIR=/storage/hpc/mpi
ARG HOST_APP_DIR=/storage/hpc/benchmark
ARG HOST_MODULEFILES_DIR=modulefiles
ARG INTEL_SN
ENV DEBIAN_FRONTEND=noninteractive

# use bash as shell
SHELL ["/bin/bash", "-c"]

# apt
RUN apt update -y && \
	apt install -y --reinstall systemd iptables && \
	apt install -y \
	gcc g++ gfortran make cmake wget git ssh tcl python3 vim locate bash-completion\
	net-tools iputils-ping iproute2 curl \
	environment-modules \
	libnss3 libgtk2.*common libpango-1* libasound2* xserver-xorg cpio \
	libgtk-3-dev libssl-dev linux-headers-$(uname -r) \
	autoconf automake \
	libibverbs-dev libatlas3-base \
	numactl libnuma-dev \
	tcl-dev tk-dev mesa-common-dev libjpeg-dev libtogl-dev 
	
	# libxt-dev \
    # libxaw7-dev \ 
    # libncurses5-dev
	# tmux

# intel
COPY ${HOST_MPI_DIR} ${MPIDIR}
RUN cd ${MPIDIR} && \
	tar zxvf parallel_studio_xe_2020_cluster_edition.tgz && \
	rm parallel_studio_xe_2020_cluster_edition.tgz && \
	cd parallel_studio_xe_2020_cluster_edition && \
	sed -ine 's/ACCEPT_EULA=decline/ACCEPT_EULA=accept/' silent.cfg && \
	sed -ine 's/ARCH_SELECTED=ALL/ARCH_SELECTED=INTEL64/' silent.cfg && \
	sed -inre "s/#ACTIVATION_SERIAL_NUMBER=snpat/ACTIVATION_SERIAL_NUMBER=${INTEL_SN}/" silent.cfg && \
	sed -ine 's/ACTIVATION_TYPE=exist_lic/ACTIVATION_TYPE=serial_number/' silent.cfg && \
	./install.sh --silent silent.cfg

# openmpi-with-cuda
RUN	cd ${MPIDIR} && \
	# wget https://download.open-mpi.org/release/open-mpi/v3.1/openmpi-3.1.5.tar.gz && \
	tar -zxvf openmpi-3.1.5.tar.gz && \
	rm openmpi-3.1.5.tar.gz && \
	cd openmpi-3.1.5 && \
	mkdir ${MPIDIR}/openmpi && \
	./configure --with-cuda --prefix=${MPIDIR}/openmpi/ompi_3.1.5 && \
	make -j$(nproc) && \
	make install -j$(nproc) 

# module file and root ssh permition
COPY ${HOST_MODULEFILES_DIR} ${APPDIR}/modulefiles
RUN source /etc/profile.d/modules.sh && \
	module use ${APPDIR}/modulefiles && \
	sed-i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/g' /etc/ssh/sshd_config
