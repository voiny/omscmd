#!/bin/bash

source ./conf.sh

if [ "$1" == "first" ]; then
	sed '1d' -i ${WORKSPACE}/list 
elif [ "$1" == "last" ]; then
	sed '$d' -i ${WORKSPACE}/list
elif [ "$1" == "source_path" ]; then
	sed "s#${SRCPATH}##" -i ${WORKSPACE}/list 
fi
