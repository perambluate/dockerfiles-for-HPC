#!/bin/bash

df=bert/Dockerfile
tag=bert-test
base="nvcr.io/nvidia/tensorflow:20.03-tf1-py3"

 while [[ -n $@ ]]; do
        temp=$1
        case ${temp%%=*} in
            "df")
                df=${df:-${temp#df=}};;
            "tag")
                tag=${tag:-${temp#tag=}};;
            "base")
                base=${base:-${temp#base=}};;
            *)
                echo "Wrong input, please input as following"
		echo "df=<path_to_Dockerfile> tag=<tag_for_docker_image> base=<the_base_image_for_building>"
                return 1;;
        esac
        shift
    done

docker pull $base
docker build --file $df --rm -t $tag --build-arg BASE=$base .
