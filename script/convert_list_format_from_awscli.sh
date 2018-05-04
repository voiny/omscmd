#!/bin/bash

cd ${ORIGINAL_DIRECTORY}
source ./conf.sh

LINE=$1
cd ${WORKSPACE}/lists
cat ${LINE} | awk '{for (i=4 ;i<=NF;i++) printf $1 " " $2 " " $i " " $3; printf "\n" }' > ${WORKSPACE}/converted_lists/${LINE}_converted_format
cat ${LINE} | awk '{"date -d \""$1 " " $2"\" +%s000"|getline v; for (i=4;i<=NF;i++) printf v " " $i " " $3; printf "\n" }' > ${WORKSPACE}/converted_lists/${LINE}_converted_format
