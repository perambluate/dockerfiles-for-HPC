#!/bin/bash
VER=3.1.5
MPIDIR=/opt/mpi
DOWNLOAD=/tmp
URL=https://download.open-mpi.org/release/open-mpi/v3.1/openmpi-${VER}.tar.gz

if [ $# != 0 ];then
    if [[ $1 =~ [^[34]\.[0-9]\.[0-9] ]]; then
        echo "Unsurported version of Open MPI!!!"
        exit 1;
    elif [[ $1 =~ ^3\.* ]]; then
        VER=$1
        URL=https://download.open-mpi.org/release/open-mpi/v3.1/openmpi-${VER}.tar.gz
    else
        URL=https://download.open-mpi.org/release/open-mpi/v4.0/openmpi-${VER}.tar.gz
    fi
    if [[ -n $2 ]]; then
        $MPIDIR=$2
    fi
fi

wget -P $DOWNLOAD $URL && \
tar -zxvf $DOWNLOAD/openmpi-${VER}.tar.gz -C $MPIDIR && \
rm $DOWNLOAD/openmpi-${VER}.tar.gz && \
mkdir -p $MPIDIR/openmpi && \
cd $MPIDIR/openmpi-${VER} && \
CC=gcc FC=gfortran ./configure --with-cuda --prefix=$MPIDIR/openmpi/$VER && \
make -j$(nproc) && make install -j$(nproc)
