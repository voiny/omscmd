#!/bin/bash

#The format of style customized2 is: timestamp(13 digits) key size

if [ "${ORIGINAL_DIRECTORY}" != "" ]; then
	cd ${ORIGINAL_DIRECTORY}
fi
source ./conf.sh

LINE=$1
REMOVE_STRING=$2
cd ${WORKSPACE}/lists
cat ${LINE} | awk '{ for (i=2;i<NF;i++) printf("%s ", $i); printf "\n"}' > ${WORKSPACE}/converted_lists/${LINE}_converted_format

