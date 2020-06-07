#!/bin/bash
VER=3.1.5
MPIDIR=/opt
DOWNLOAD=/tmp
URL=

if [ $# != 0 ];then
    if [[ $1 =~ ^3\.1\.* ]]; then
        VER=$1
        URL=https://download.open-mpi.org/release/open-mpi/v3.1/openmpi-${VER}.tar.gz
    elif [[ $1 =~ ^4\.0\.* ]]; then
        URL=https://download.open-mpi.org/release/open-mpi/v4.0/openmpi-${VER}.tar.gz
    else
        echo "Unsurported version of Open MPI!!!"
        exit 1;
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
