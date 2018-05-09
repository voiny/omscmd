#!/bin/bash

export ORIGINAL_DIRECTORY=$(pwd)
source ./conf.sh

DEFAULT_COMPARE_OUTPUT_PATH=${WORKSPACE}/compare_result
COMPARE_OUTPUT_PATH=${DEFAULT_COMPARE_OUTPUT_PATH}
OUTPUT_PATH=${WORKSPACE}/batch_tasks

rm -rf ${OUTPUT_PATH}
mkdir -p ${OUTPUT_PATH}

if [ "$1" != "" ];then
	COMPARE_OUTPUT_PATH=$1
fi

LISTS=`ls ${COMPARE_OUTPUT_PATH}/diff`
for LINE in ${LISTS}
do
	/usr/bin/cp ${COMPARE_OUTPUT_PATH}/diff/${LINE} ${WORKSPACE}/list -rf
	./split_list.sh
	./lists2tasks.sh
	rename "list-" "${LINE}_list-" ${WORKSPACE}/tasks/*
	/usr/bin/mv ${WORKSPACE}/tasks/* ${OUTPUT_PATH}/
done

