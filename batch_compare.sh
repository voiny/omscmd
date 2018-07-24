#!/bin/bash

export ORIGINAL_DIRECTORY=$(pwd)
cd script
source ./conf.sh
cd ..

CMP_SRC_PATH=$1
CMP_DST_PATH=$2
CMP_TIME=$3

COMPARE_WORKSPACE=${WORKSPACE}/compare_workspace
OUTPUT_PATH=${WORKSPACE}/compare_result

function usage()
{
	echo "[command] [SRC_PATH_CONTAINTING_LISTS] [DST_PATH_CONTAINING_LISTS] [-t:Compare timestamp]"
	echo "Output: ${OUTPUT_PATH}/*" 
}

if [[ "${CMP_SRC_PATH}" == "" || "${CMP_SRC_PATH}" == "" ]];then
	usage
	exit
fi

rm -rf ${OUTPUT_PATH}
mkdir -p ${OUTPUT_PATH}
mkdir -p ${OUTPUT_PATH}/diff
mkdir -p ${OUTPUT_PATH}/same

LISTS=`ls ${CMP_SRC_PATH}`
for LINE in ${LISTS}
do
	echo ./oms_compare.py -s ${CMP_SRC_PATH}/${LINE} -d ${CMP_DST_PATH}/${LINE} -n 1 -w ${COMPARE_WORKSPACE}/  ${CMP_TIME}
	./oms_compare.py -s ${CMP_SRC_PATH}/${LINE} -d ${CMP_DST_PATH}/${LINE} -n 1 -w ${COMPARE_WORKSPACE}/  ${CMP_TIME}
	BUCKETNAME=`echo ${LINE} | sed 's/result-//'`
	mv ${COMPARE_WORKSPACE}/result_files/result_same_file ${OUTPUT_PATH}/same/${BUCKETNAME}
	mv ${COMPARE_WORKSPACE}/result_files/result_diff_file ${OUTPUT_PATH}/diff/${BUCKETNAME}
done

