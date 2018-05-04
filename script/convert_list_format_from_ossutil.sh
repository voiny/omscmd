#!/bin/bash

if [ "${ORIGINAL_DIRECTORY}" != "" ]; then
	cd ${ORIGINAL_DIRECTORY}
fi
source ./conf.sh

LINE=$1
REMOVE_STRING=$2
cd ${WORKSPACE}/lists
cat ${LINE} | awk '{"date -d \""$1 " " $2"\" +%s000"|getline v; for (i=8;i<=NF;i++) printf v " " $i " " $5; printf "\n" }' > ${WORKSPACE}/converted_lists/${LINE}_converted_format

if [ "${REMOVE_STRING}" != ""  ]; then
	sed "s#${REMOVE_STRING}##" -i ${WORKSPACE}/converted_lists/${LINE}_converted_format
fi
