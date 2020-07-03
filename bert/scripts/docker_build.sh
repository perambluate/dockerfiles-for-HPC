#!/bin/bash

df=bert/Dockerfile
tag=bert-test
ompi="nvidia/cuda:10.2-devel-ubuntu16.04"
bert="nvcr.io/nvidia/tensorflow:20.03-tf1-py3"

while [[ -n $@ ]]; do
    temp=$1
    case ${temp%%=*} in
        "df")
            df=${df:-${temp#df=}};;
        "tag")
            tag=${tag:-${temp#tag=}};;
        "bert")
            bert=${bert:-${temp#bert=}};;
	    "ompi")
		    ompi=${ompi:-${temp#ompi=}};;
        *)
            echo "Wrong input, please input as following"
		    echo "df=<path_to_Dockerfile> \
                tag=<tag_for_docker_image> \
                bert=<the_base_image_for_bert_container> \
                ompi=<the_base_image_for_openmpi_installation>"
            exit 1;;
    esac
    shift
done

DockerIMG(){
    while [[ -n $@ ]]; do
	temp=$1
        [[ -n `docker images -q $temp 2> /dev/null` ]] || docker pull $temp
   	shift
    done
}

DockerIMG $bert $ompi
docker build --file $df --rm -t $tag --build-arg BERT_BASE=$bert --build-arg OMPI_BASE=$ompi .
