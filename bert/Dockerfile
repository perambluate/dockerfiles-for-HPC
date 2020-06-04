ARG BASE=nvcr.io/nvidia/tensorflow:20.03-tf1-py3
FROM $BASE


# arguments and env in building time
ARG HOST_MODULEFILES_DIR=modulefiles
ARG HOST_SCRIPTS=bert/scripts
ARG HOST_DOWNLOAD_LIST=bert/downloadlist
ARG OMPI_VER=3.1.5
ENV DEBIAN_FRONTEND=noninteractive LANG=C LC_ALL=C
ENV WORKDIR=/workspace \
    DATA=$WORKDIR/data \
    CODE=$WORKDIR/github \
    MODEL=$WORKDIR/model \
    DOWNLOAD=$WORKDIR/download \
    SCRIPTS=$WORKDIR/scripts \
    MODULEFILES=$WORKDIR/modulefiles \
    MPIDIR=/opt/mpi

RUN mkdir -p $WORKDIR && \
    mkdir -p $DATA $CODE $MODEL $DOWNLOAD && \
    apt update && apt install -y gfortran wget git unzip python3-pip

COPY $HOST_DOWNLOAD_LIST $WORKDIR
# download bert pretrained model & dataset
WORKDIR $WORKDIR
RUN wget -P $DOWNLOAD -i downloadlist &&\
    python3 $DOWNLOAD/download_glue_data.py --tasks all --data_dir $DATA/glue_data &&\
    unzip "$DOWNLOAD/*.zip" -d $MODEL &&\
    git clone https://github.com/google-research/bert.git $CODE/google &&\
    git clone https://github.com/NVIDIA/DeepLearningExamples.git $CODE/nvidia

COPY $HOST_SCRIPTS $SCRIPTS
RUN mkdir -p $MPIDIR && source $SCRIPTS/openmpi_install.sh $OMPI_VER $MPIDIR
COPY $HOST_MODULEFILES_DIR $MODULEFILES
