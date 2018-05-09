#!/bin/bash

#Batch-process: convert multi-lists into destination format

source ./conf.sh

TYPE=$1
LIST_PATH=$2
REMOVE_STRING=$3
OUTPUT_PATH=${WORKSPACE}/converted_full_lists

function usage()
{
	echo "[command] [TYPE:ossutil/awscli/...] [PATH_CONTAINING_FULL_LIST(S)] (REMOVE_STRING)"
	echo "Output: ${OUTPUT_PATH}/*" 
}

if [[ "${LIST_PATH}" == "" || "${TYPE}" == "" ]];then
	usage
	exit
fi

rm -rf ${OUTPUT_PATH}
mkdir -p ${OUTPUT_PATH}

LISTS=`ls ${LIST_PATH}`
for LINE in ${LISTS}
do
	echo Processing ${LINE}...
	/usr/bin/cp ${LIST_PATH}/${LINE} ${WORKSPACE}/list -rf
	${ORIGINAL_DIRECTORY}/split_list.sh
	${ORIGINAL_DIRECTORY}/convert_lists_format.sh ${TYPE} ${REMOVE_STRING}
	mv ${WORKSPACE}/converted_list ${OUTPUT_PATH}/${LINE}_${TYPE}_converted_list
done

