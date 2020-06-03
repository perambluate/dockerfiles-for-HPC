#!/bin/bash

DKF=Dockerfile
CTN=bert
BASE="nvcr.io/nvidia/tensorflow:20.03-tf1-py3"

if [ $# != 0 ]; then
    echo "Please input BASE DKF CTN in order"
    DKF=$1
    CTN=${2:-$CTN}
    BASE=${3:-$BASE}
fi

docker pull $BASE
docker build --file bert/$DKF --rm -t $CTN --build-arg BASE=$BASE .
