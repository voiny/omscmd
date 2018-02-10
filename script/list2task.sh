#!/bin/bash

if [ "${ORIGINAL_DIRECTORY}" != "" ]; then
	source ${ORIGINAL_DIRECTORY}/conf.sh
else
	source ./conf.sh
fi

ONE_LIST_FILE=$1
TABLE_FILE=$2

function help() {
	echo Usage: list2task list_file
}

function convert_list_to_task() {
	LIST=`cat ${ONE_LIST_FILE}`
	KEYS=''
	for LINE in ${LIST}
	do
		KEYS=\"${LINE}\"
		break
	done
	for LINE in ${LIST}
	do
		KEYS=${KEYS},\"${LINE}\"
	done
	echo "curl -H 'Content-Type:application/json' --insecure -X POST --data '{\"src_node\":{\"region\":\"${SRCREGION}\",\"ak\":\"${SRCAK}\",\"sk\":\"${SRCSK}\",\"object_key\":{\"path\":\"${SRCPATH_SHORT}\",\"keys\":[${KEYS}]},\"bucket\":\"${SRCBUCKETNAME}\",\"cloud_type\":\"${SRCCLOUDTYPE}\"},\"thread_num\":${THREAD_PER_TASK},\"enableKMS\":${ENABLE_KMS},\"description\":\"${DESC_PREFIX}_${ONE_LIST_FILE}\",\"dst_node\":{\"region\":\"${DSTREGION}\",\"ak\":\"${DSTAK}\",\"sk\":\"${DSTSK}\",\"object_key\":\"${DSTPATH_SHORT}\",\"bucket\":\"${DSTBUCKETNAME}\",\"cloud_type\":\"OTC\"}}' https://127.0.0.1:8099/v1/0000000000/objectstorage/task" > ${ONE_LIST_FILE}_task.sh
	chmod 550 ${ONE_LIST_FILE}_task.sh
	if [ "${TABLE_FILE}" != "" ];then
		echo ${ONE_LIST_FILE}	${KEYS} >> ${TABLE_FILE}
	fi
}

if [ "${ONE_LIST_FILE}" == "" ]; then
	help
else
	convert_list_to_task
fi
