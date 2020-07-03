#!/bin/bash

IMG=yonoia/bert:ngc-tf1-20.03-ompi-3.1.5
NAME=test

while [[ -n $@ ]]; do
    temp=$1
    case ${temp%%=*} in
	"name")
	    printf "yes %s\n" ${temp#name=}
	    NAME=${NAME:-${temp#name=}}
	    printf "yes %s\n" $NAME;;
	"img")
	    temp=${temp#img=}
	    [[ -n $temp ]] && [[ -n `docker images -q $temp 2> /dev/null` ]] && IMG=$temp;;
	*)
	    echo "Wrong input, please input as following"
	    echo "name=<name_of_container> img=<image_for_container_to_run>"
    esac
    shift
done

if [[ -n `docker ps -a --format '{{.Names}}' | grep "$NAME"` ]]; then
    printf "the container %s exits\n" $NAME
else
    docker run --shm-size=1g --ulimit memlock=-1 --ulimit stack=67108864 -it --runtime=nvidia --name="${NAME}" ${IMG}
fi
