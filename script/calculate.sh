#!/bin/bash

source ./conf.sh

SUBLISTS_PATH=$1
RESULT_PATH=${WORKSPACE}/calculate
if [ "${S3ANALYZER_PATH}" == "" ];then
	export S3ANALYZER_PATH=/root/s3analyzer
fi

if [ "${SUBLISTS_PATH}" != "" ];then
	rm -rf ${RESULT_PATH}
	mkdir -p ${RESULT_PATH}
	touch ${RESULT_PATH}/calculate_merge
	COUNTER_LIST=0
	COUNTER_OBJINLIST=0
	LIST_FILES=`ls ${SUBLISTS_PATH}`
	LIST_COUNT=`ls ${SUBLISTS_PATH} | wc -l`
	cd ${S3ANALYZER_PATH}
	
	for LIST_FILE in ${LIST_FILES}
	do
		let COUNTER_LIST+=1
		LIST=`cat ${LISTS_PATH}/${LIST_FILE}`
		echo TASK ${COUNTER_LIST} ${LIST_FILE} is starting:
		let COUNTER_OBJINLIST+=1
		echo "./s3comparer.py --calculate-size -i ${SUBLISTS_PATH}/${LIST_FILE} &"
		./s3comparer.py --calculate-size -i ${SUBLISTS_PATH}/${LIST_FILE} -o ${RESULT_PATH}/calculate_${COUNTER_LIST}_${LIST_FILE} -t 1 &
	done
	wait
	cat ${RESULT_PATH}/calculate_* >> ${RESULT_PATH}/calculatemerge
	./s3comparer.py --calculate-size -i ${RESULT_PATH}/calculatemerge -o ${WORKSPACE}/calculate_final -t 1
fi
