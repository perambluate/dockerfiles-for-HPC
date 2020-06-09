ARG OMPI_BASE=nvidia/cuda:10.2-devel-ubuntu16.04
ARG BERT_BASE=nvcr.io/nvidia/tensorflow:20.03-tf1-py3

FROM ${OMPI_BASE} AS ompi_builder

ARG HOST_SCRIPTS=scripts/
ARG OMPI_VER=3.1.5
ARG OMPI_INSTALL_SCRIPT=ompi_install.sh

ENV TMP=/tmp \
    MPIDIR=/opt

SHELL ["/bin/bash", "-c"]

WORKDIR /opt
COPY ${HOST_SCRIPTS}/${OMPI_INSTALL_SCRIPT} .
RUN apt update && apt install -y gfortran wget &&\
    mkdir -p ${MPIDIR} && source ./${OMPI_INSTALL_SCRIPT} ${OMPI_VER} ${MPIDIR}

FROM ${BERT_BASE}

# arguments and env in building time
ARG HOST_SCRIPTS=scripts/
ARG NCCL_INSTALL_SCRIPT=nccl_install.sh
ARG HOST_MODULEFILES_DIR=modulefiles
ARG HOST_DOWNLOAD_LIST=bert/downloadlist

ENV DEBIAN_FRONTEND=noninteractive LANG=C LC_ALL=C
ENV OMPI_VER=3.1.5
ENV WORKDIR=/workspace
ENV DATA=${WORKDIR}/data \
    CODE=${WORKDIR}/github \
    MODEL=${WORKDIR}/model \
    SCRIPTS=${WORKDIR}/scripts \
    MODULEFILES=${WORKDIR}/modulefiles \
    TMP=/tmp \
    OMPIDIR=/opt/openmpi/${OMPI_VER}

SHELL ["/bin/bash", "-c"]

RUN mkdir -p ${WORKDIR} && \
    mkdir -p ${DATA} ${CODE} ${MODEL} ${TMP} ${MODULEFILES} && \
    apt update && \
    apt install -y gfortran wget git unzip python3-pip python3-dev \
	tcl environment-modules

COPY ${HOST_DOWNLOAD_LIST} ${WORKDIR}
# download bert pretrained model & dataset
WORKDIR ${WORKDIR}
RUN wget -P ${TMP} -i downloadlist &&\
    python3 ${TMP}/download_glue_data.py --tasks MNLI --data_dir ${DATA} &&\
    unzip "${TMP}/*.zip" -d $MODEL &&\
    git clone https://github.com/google-research/bert.git $CODE/google &&\
    git clone https://github.com/NVIDIA/DeepLearningExamples.git $CODE/nvidia

#install NCCL
COPY ${HOST_SCRIPTS}/${NCCL_INSTALL_SCRIPT} .
RUN source ./${NCCL_INSTALL_SCRIPT}

COPY ${HOST_MODULEFILES_DIR}/general/mpi/open ${MODULEFILES}/mpi/open
COPY ${HOST_MODULEFILES_DIR}/bert ${MODULEFILES}/bert
COPY --from=ompi_builder ${OMPIDIR} ${OMPIDIR}
RUN ln -sf /usr/local/python3 /usr/local/python &&\
    python -m pip install -U pip && \
    python -m pip install -U setuptools && \
    # python3 -m pip install tensorflow-gpu==1.15 && \
    source /etc/profile.d/modules.sh && \
    module use ${MODULEFILES} &&\
    module load mpi/open/${OMPI_VER} &&\
    HOROVOD_GPU_ALLREDUCE=NCCL \
    HOROVOD_NCCL_HOME=/opt/nccl/build/ \
    python -m pip install --no-cache-dir horovod==0.16
