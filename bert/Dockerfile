ARG OMPI_BASE=nvidia/cuda:10.2-devel-ubuntu16.04
FROM $OMPI_BASE AS ompi_builder

ARG OMPI_VER=3.1.5
ARG HOST_SCRIPTS=scripts/ompi_install.sh

ENV TMP=/tmp \
    MPIDIR=/opt/mpi

WORKDIR /opt
COPY $HOST_SCRIPTS .
RUN apt update && apt install -y gfortran wget &&\
    mkdir -p $MPIDIR && source ./openmpi_install.sh $OMPI_VER $MPIDIR

ARG BASE=nvcr.io/nvidia/tensorflow:20.03-tf1-py3
FROM $BASE

# arguments and env in building time
ARG HOST_MODULEFILES_DIR=modulefiles
ARG HOST_DOWNLOAD_LIST=bert/downloadlist

ENV DEBIAN_FRONTEND=noninteractive LANG=C LC_ALL=C
ENV WORKDIR=/workspace
ENV DATA=$WORKDIR/data \
    CODE=$WORKDIR/github \
    MODEL=$WORKDIR/model \
    SCRIPTS=$WORKDIR/scripts \
    MODULEFILES=$WORKDIR/modulefiles \
    TMP=/tmp

RUN mkdir -p $WORKDIR && \
    mkdir -p $DATA $CODE $MODEL $TMP && \
    apt update && \
    apt install -y gfortran wget git unzip python3-pip python3-dev \
	tcl environment-modules

COPY $HOST_DOWNLOAD_LIST $WORKDIR
# download bert pretrained model & dataset
WORKDIR $WORKDIR
RUN wget -P $TMP -i downloadlist &&\
    python3 $TMP/download_glue_data.py --tasks MNLI --data_dir $DATA &&\
    unzip "$TMP/*.zip" -d $MODEL &&\
    git clone https://github.com/google-research/bert.git $CODE/google &&\
    git clone https://github.com/NVIDIA/DeepLearningExamples.git $CODE/nvidia

COPY $HOST_MODULEFILES_DIR $MODULEFILES
RUN ln -sf /usr/local/python3 /usr/local/python &&\
    python3 -m pip install -U pip && \
    python3 -m pip install -U setuptools && \
    # python3 -m pip install tensorflow-gpu==1.15 && \
    source /etc/profile.d/modules.sh && \
    module use ${MODULEFILES} &&\
    module load mpi/intel &&\
    HOROVOD_GPU_ALLREDUCE=NCCL \
    HOROVOD_NCCL_HOME=/usr/lib/x86_64-linux-gnu \
    python3 -m pip install --no-cache-dir horovod==0.16