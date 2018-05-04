#!/bin/bash

source ./conf.sh

if [ "$2" == "first" ]; then
	sed '1d' -i ${WORKSPACE}/list 
elif [ "$2" == "last" ]; then
	sed '$d' -i ${WORKSPACE}/list
elif [ "$2" == "source_path" ]; then
	sed "s#${SRCPATH}##" -i ${WORKSPACE}/list 
fi
