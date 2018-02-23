#!/bin/bash

source ./conf.sh

LISTS_PATH=${WORKSPACE}/lists
RESULT_PATH=${WORKSPACE}/sublists
rm -rf ${RESULT_PATH}
mkdir -p ${RESULT_PATH}

START=$1
END=$2
COUNTER_LIST=0
COUNTER_OBJINLIST=0
LIST_FILES=`ls ${LISTS_PATH}`
LIST_COUNT=`ls ${LISTS_PATH} | wc -l`

if [[ "${START}" == "" || "${END}" == "" ]];then
	for LIST_FILE in ${LIST_FILES}
	do
		let COUNTER_LIST+=1
		LIST=`cat ${LISTS_PATH}/${LIST_FILE}`
		echo TASK ${COUNTER_LIST} ${LIST_FILE} is starting:
		for OBJ in ${LIST}
		do
			let COUNTER_OBJINLIST+=1
			echo "${SRCTOOL} ls s3://${SRCBUCKETNAME}${SRCPATH_SHORT}${OBJ} --recursive | tee ${RESULT_PATH}/sublist_${LIST_FILE}_${COUNTER_LIST}_${COUNTER_OBJINLIST} &"
			${SRCTOOL} ls s3://${SRCBUCKETNAME}${SRCPATH_SHORT}${OBJ} --recursive | tee ${RESULT_PATH}/sublist_${LIST_FILE}_${COUNTER_LIST}_${COUNTER_OBJINLIST} &
		done
	done
	wait
	cat ${RESULT_PATH}/sublist_* > ${WORKSPACE}/sublist_result_all
else
	echo
	idx=0
	TASKS_FILES_ARRAY={}
	for LIST_FILE in ${LIST_FILES}
	do
		echo ------------ ${LIST_FILE}
		TASKS_FILES_ARRAY[${idx}]=${LIST_FILE}
		let idx+=1
	done
	# START and END are not empty
	if [[ ${START} -le ${LIST_COUNT} && ${START} -ge 0 ]];then
		if [ ${END} -ge ${LIST_COUNT} ];then
			let END=${LIST_COUNT}
			let END-=1
		fi
		if [ ${END} -ge 0 ]; then
			SEQ=`seq ${START} ${END}`
			for idx in $SEQ
			do
				let COUNTER_LIST+=1
				LIST_FILE=${TASKS_FILES_ARRAY[${idx}]}
				LIST=`cat ${LISTS_PATH}/${LIST_FILE}`
				echo TASK ${COUNTER_LIST} ${LIST_FILE} is starting:
				for OBJ in ${LIST}
				do
					let COUNTER_OBJINLIST+=1
					echo "${SRCTOOL} ls s3://${SRCBUCKETNAME}${SRCPATH_SHORT}${OBJ} --recursive | tee ${RESULT_PATH}/sublist_${LIST_FILE}_${COUNTER_LIST}_${COUNTER_OBJINLIST} &"
					${SRCTOOL} ls s3://${SRCBUCKETNAME}${SRCPATH_SHORT}${OBJ} --recursive | tee ${RESULT_PATH}/sublist_${LIST_FILE}_${COUNTER_LIST}_${COUNTER_OBJINLIST} &
				done
			done
		fi
	fi
	wait
	cat ${RESULT_PATH}/sublist_* > ${WORKSPACE}/sublist_result_${START}_to_${END}
fi


