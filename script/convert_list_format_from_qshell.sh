#!/bin/bash

if [ "${ORIGINAL_DIRECTORY}" != "" ]; then
	cd ${ORIGINAL_DIRECTORY}
fi
source ./conf.sh

LINE=$1
REMOVE_STRING=$2
cd ${WORKSPACE}/lists
cat ${LINE} | awk '{t1=substr($4,0,13);printf t1; for (i=1;i<NF-4;i++) printf(" %s", $i); printf "\n" }' > ${WORKSPACE}/converted_lists/${LINE}_converted_format
