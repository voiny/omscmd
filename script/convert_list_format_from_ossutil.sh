#!/bin/bash

if [ "${ORIGINAL_DIRECTORY}" != "" ]; then
	cd ${ORIGINAL_DIRECTORY}
fi
source ./conf.sh

LINE=$1
REMOVE_STRING=$2
cd ${WORKSPACE}/lists
if [ "${REMOVE_STRING}" != ""  ]; then
	cat ${LINE} | awk '{gsub("-"," ",$1); gsub(":", " ",$2); sub("'${REMOVE_STRING}'", "", $8); t1=mktime($1 " " $2); printf t1 "000 "; for (i=8;i<=NF;i++) printf("%s", $i); printf $5 "\n" }' > ${WORKSPACE}/converted_lists/${LINE}_converted_format
#	sed "s#${REMOVE_STRING}##" -i ${WORKSPACE}/converted_lists/${LINE}_converted_format
else
	cat ${LINE} | awk '{gsub("-"," ",$1); gsub(":", " ",$2); t1=mktime($1 " " $2); printf t1 "000 "; for (i=8;i<=NF;i++) printf("%s", $i); printf $5 "\n" }' > ${WORKSPACE}/converted_lists/${LINE}_converted_format
fi
