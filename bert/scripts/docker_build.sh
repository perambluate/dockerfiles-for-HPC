#!/bin/bash

fn=Dockerfile
tag=bert-test
base="nvcr.io/nvidia/tensorflow:20.03-tf1-py3"

 while [[ -n $@ ]]; do
        temp=$1
        case ${temp%%=*} in
            "fn")
                fn=${temp#fn=};;
            "tag")
                tag=${temp#tag=};;
            "base")
                base=${temp#base=};;
            *)
                echo "Wrong input, please check this shell script"
                return 1;;
        esac
        shift
    done

docker pull $base
docker build --file bert/$fn --rm -t $tag --build-arg BASE=$base .
