FROM ubuntu:18.04 
MAINTAINER t3

# apt
RUN apt update \
	&& apt install gcc -y \
	&& apt install g++ -y \
	&& apt install make -y \
	&& apt install wget -y \
	&& apt install git -y \
	&& apt install python3 -y \
	&& apt install python3-pip -y \
	&& apt install libatlas3-base -y \
	&& apt install vim -y \
	&& apt install locate -y \
	&& apt install ssh -y \
	&& apt install iputils-ping -y \
	&& apt install iproute2 -y \
	&& apt install curl -y \
	&& apt install --reinstall systemd -y \
	&& apt install --reinstall iptables -y

# cpu info
ARG CPUCOUNT

# openmpi-3.1.4
RUN	cd \
	&& wget https://download.open-mpi.org/release/open-mpi/v3.1/openmpi-3.1.4.tar.gz \
	&& tar -zxvf openmpi-3.1.4.tar.gz \
	&& cd openmpi-3.1.4 \
	&& ./configure --prefix=$HOME/openmpi \
	&& make -j${CPUCOUNT} \
	&& make install -j${CPUCOUNT} 
ENV PATH="$PATH:/root/openmpi/bin" 
ENV LD_LIBRARY_PATH="$LD_LIBRARY_PATH:/root/openmpi/lib"
ENV OMPI_MCA_btl_vader_single_copy_mechanism="none"

# hpl-2.3
RUN cd \
	&& wget https://www.netlib.org/benchmark/hpl/hpl-2.3.tar.gz \
	&& tar -zxvf hpl-2.3.tar.gz \
	&& cd hpl-2.3 \
	&& cp setup/Make.Linux_ATHLON_CBLAS . \
	&& sed -ie 's/\$(HOME)\/hpl/\$(HOME)\/hpl-2.3/' Make.Linux_ATHLON_CBLAS \
	&& sed -ie 's/\/usr\/local\/mpi/\$(HOME)\/openmpi/' Make.Linux_ATHLON_CBLAS \
	&& sed -ie 's/\$(MPdir)\/lib\/libmpich.a/\$(MPdir)\/lib\/libmpi.so/' Make.Linux_ATHLON_CBLAS \
	&& sed -ie 's/\$(HOME)\/netlib\/ARCHIVES\/Linux_ATHLON/\/usr\/lib\/x86_64-linux-gnu/' Make.Linux_ATHLON_CBLAS \
	&& sed -ie 's/\$(LAdir)\/libcblas.a \$(LAdir)\/libatlas.a/\$(LAdir)\/libcblas.so.3 \$(LAdir)\/libatlas.so.3/' Make.Linux_ATHLON_CBLAS \
	&& make arch=Linux_ATHLON_CBLAS -j${CPUCOUNT} 

#Linpack
RUN cd \
	&& wget https://software.intel.com/sites/default/files/managed/e4/1c/l_mklb_p_2019.5.004.tgz \
	&& tar -xvf l_mklb_p_2019.5.004.tgz \
	&& cd l_mklb_p_2019.5.004/benchmarks_2019/linux/mkl/benchmarks/linpack \

# hpcg-3.1
RUN cd \
	&& wget http://www.hpcg-benchmark.org/downloads/hpcg-3.1.tar.gz \
	&& tar -zxvf hpcg-3.1.tar.gz \
	&& cd hpcg-3.1 \
	&& mkdir build \
	&& cd build \
	&& ../configure Linux_MPI \
	&& make -j${CPUCOUNT} 

# hpcc-1.5.0
RUN cd \
	&& wget http://icl.cs.utk.edu/projectsfiles/hpcc/download/hpcc-1.5.0.tar.gz \
	&& tar -zxvf hpcc-1.5.0.tar.gz \
	&& cd hpcc-1.5.0 \
	&& cp hpl/setup/Make.Linux_ATHLON_CBLAS hpl/ \
	&& sed -ie 's/\.\.\/\.\.\/\.\./\$(HOME)\/hpcc-1.5.0\/hpl/' hpl/Make.Linux_ATHLON_CBLAS \
	&& sed -ie 's/\/usr\/local\/mpi/\$(HOME)\/openmpi/' hpl/Make.Linux_ATHLON_CBLAS \
	&& sed -ie 's/\$(MPdir)\/lib\/libmpich.a/\$(MPdir)\/lib\/libmpi.so/' hpl/Make.Linux_ATHLON_CBLAS \
	&& sed -ie 's/\$(HOME)\/netlib\/ARCHIVES\/Linux_ATHLON/\/usr\/lib\/x86_64-linux-gnu/' hpl/Make.Linux_ATHLON_CBLAS \
	&& sed -ie 's/\$(LAdir)\/libcblas.a \$(LAdir)\/libatlas.a/\$(LAdir)\/libcblas.so.3 \$(LAdir)\/libatlas.so.3/' hpl/Make.Linux_ATHLON_CBLAS \
	&& make arch=Linux_ATHLON_CBLAS -j${CPUCOUNT} 
#ssh-key
#RUN cd \
	#&& ip addr show | grep "10.0.0.[0-9]\{3\}" | awk '{print $2}' | cut -d "/" -f 1 >> /etc/hosts
	#&& ssh-keygen \
	#&& ssh-copy-id 
# numpy & tensorflow
#RUN cd \
#	&& pip3 install numpy==1.16.4 \
#	&& pip3 install tensorflow==1.13.2 \
#	&& git clone https://github.com/tensorflow/models.git \
#	&& cd models \
#	&& git checkout r1.13.0

# spyder 
#RUN pip3 install spyder

# jupyter
#RUN pip3 install jupyter

#ENV PATH="$PATH:/home/ncku/.local/bin"
EXPOSE 22

