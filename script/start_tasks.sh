#!/bin/bash

source ./conf.sh

cd ${WORKSPACE}/tasks

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
		./${TASKFILE}
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
				echo ./${TASKS_FILES_ARRAY[${idx}]} 
				echo
			done
		fi
	fi
fi

echo Started ${COUNTER}/${TASK_COUNT} tasks.
