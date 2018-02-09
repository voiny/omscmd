#!/bin/bash

source ./env.sh

cd ${WORKSPACE}

wget https://bootstrap.pypa.io/get-pip.py

python get-pip.py

cd ${ORIGINAL_DIRECTORY}

if [ "$SRCTOOL" == "s3cmd" ]; then
	pip install s3cmd
	./conf_s3cmd.sh
else
	pip install awscli
	./conf_awscli.sh
fi



