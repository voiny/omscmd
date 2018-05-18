#!/bin/bash

if [ "${ORIGINAL_DIRECTORY}" != "" ]; then
	cd ${ORIGINAL_DIRECTORY}
fi
source ./conf.sh

LINE=$1
REMOVE_STRING=$2
cd ${WORKSPACE}/lists
if [ "${REMOVE_STRING}" != ""  ]; then
	cat ${LINE} | awk '{gsub("'${REMOVE_STRING}'", "",$2); printf $1; for (i=2;i<=NF;i++) printf(" %s", $i); printf " 0\n" }' > ${WORKSPACE}/converted_lists/${LINE}_converted_format
else
	cat ${LINE} | awk '{printf $1; for (i=2;i<=NF;i++) printf(" %s", $i); printf " 0\n" }' > ${WORKSPACE}/converted_lists/${LINE}_converted_format
fi
