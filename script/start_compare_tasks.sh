#!/bin/bash

source ./conf.sh
if [ "${S3ANALYZER_PATH}" == "" ]; then
	export S3ANALYZER_PATH=/root/s3analyzer
fi
COMPARE_RESULT_PATH=${WORKSPACE}/compare_result
rm -rf ${COMPARE_RESULT_PATH}
mkdir -p ${COMPARE_RESULT_PATH}
cd ${WORKSPACE}/lists

START=$1
END=$2

TASKS_FILES=`ls`
TASK_COUNT=`ls -l | wc -l`
COUNTER=0
let TASK_COUNT-=1

if [[ "${START}" == "" || "${END}" == "" ]];then
	for TASKFILE in ${TASKS_FILES}
	do
		let COUNTER+=1
		echo TASK ${COUNTER} ${TASKFILE} is starting:
		cd ${S3ANALYZER_PATH}
		./s3analyzer.py --cb -t 300 --cfg1 src --cfg2 dst --u1 s3://${SRCBUCKETNAME}${SRCPATH_SHORT} --u2 s3://${DSTBUCKETNAME}/${DSTPATH_SHORT} -i ${WORKSPACE}/lists/${TASKFILE} -o ${COMPARE_RESULT_PATH}/compare_result_${TASKFILE}
		echo
	done
else
	idx=0
	TASKS_FILES_ARRAY={}
	for LINE in ${TASKS_FILES}
	do
		TASKS_FILES_ARRAY[${idx}]=${LINE}
		let idx+=1
	done
	# START and END are not empty
	if [[ ${START} -le ${TASK_COUNT} && ${START} -ge 0 ]];then
		if [ ${END} -ge ${TASK_COUNT} ];then
			let END=${TASK_COUNT}
			let END-=1
		fi
		if [ ${END} -ge 0 ]; then
			SEQ=`seq ${START} ${END}`
			for idx in $SEQ
			do
				let COUNTER+=1
				echo TASK ${COUNTER} ${TASKS_FILES_ARRAY[${idx}]} is starting:
				cd ${S3ANALYZER_PATH}
				./s3analyzer.py --cb -t 300 --cfg1 src --cfg2 dst --u1 s3://${SRCBUCKETNAME}${SRCPATH_SHORT} --u2 s3://${DSTBUCKETNAME}/${DSTPATH_SHORT} -i ${WORKSPACE}/lists/${TASKS_FILES_ARRAY[${idx}]} -o ${COMPARE_RESULT_PATH}/compare_result_${TASKS_FILES_ARRAY[${idx}]}
				echo 
			done
		fi
	fi
fi

echo Started ${COUNTER}/${TASK_COUNT} tasks.
