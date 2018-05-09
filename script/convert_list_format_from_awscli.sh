#!/bin/bash

cd ${ORIGINAL_DIRECTORY}
source ./conf.sh

LINE=$1
cd ${WORKSPACE}/lists
cat ${LINE} | awk '{gsub("-"," ",$1); gsub(":", " ",$2); sub("'${REMOVE_STRING}'", "", $4); t1=mktime($1 " " $2); printf t1 "000 "; for (i=4;i<=NF;i++) printf("%s", $i); printf $3 "\n" }' > ${WORKSPACE}/converted_lists/${LINE}_converted_format
