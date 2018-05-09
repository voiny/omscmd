#!/bin/bash

#Batch-process: convert multi-lists into destination format

source ./conf.sh

TYPE=$1
LIST_PATH=$2
OUTPUT_PATH=${WORKSPACE}/converted_full_lists

function usage()
{
	echo "[command] [TYPE:ossutil/awscli/...] [PATH_CONTAINING_FULL_LIST(S)]"
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
	BUCKETNAME=`echo ${LINE} | sed 's/result-//'`
	REMOVE_STRING="oss://"${BUCKETNAME}"/"
	echo Processing ${LINE}...
	/usr/bin/cp ${LIST_PATH}/${LINE} ${WORKSPACE}/list -rf
	if [ "${TYPE}" == "ossutil" ];then
		${ORIGINAL_DIRECTORY}/remove_line.sh first
		${ORIGINAL_DIRECTORY}/remove_line.sh last
		${ORIGINAL_DIRECTORY}/remove_line.sh last
		${ORIGINAL_DIRECTORY}/split_list.sh
		${ORIGINAL_DIRECTORY}/convert_lists_format.sh ${TYPE} ${REMOVE_STRING}
	else
		${ORIGINAL_DIRECTORY}/split_list.sh
		${ORIGINAL_DIRECTORY}/convert_lists_format.sh ${TYPE}
	fi
	mv ${WORKSPACE}/converted_list ${OUTPUT_PATH}/${LINE}_${TYPE}_converted_list
done

