#!/bin/bash

if [ "${ORIGINAL_DIRECTORY}" != "" ]; then
	cd ${ORIGINAL_DIRECTORY}
fi
source ./conf.sh

LINE=$1
REMOVE_STRING=$2
cd ${WORKSPACE}/lists
cat ${LINE} | awk '{gsub("-"," ",$1); gsub(":", " ",$2); t1=mktime($1 " " $2); printf t1 "000"; for (i=5;i<=NF;i++) printf(" %s", $i); printf " " $3 "\n"}' > ${WORKSPACE}/converted_lists/${LINE}_converted_format
