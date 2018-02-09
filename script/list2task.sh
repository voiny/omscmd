#!/bin/bash

source ./conf.sh

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
	echo curl -H "Content-Type:application/json" --insecure -X POST --data "{\"src_node\":{\"region\":\"${SRCREGION}\",\"ak\":\"${SRCAK}\",\"sk\":\"${SRCSK}\",\"object_key\":{\"path\":\"${SRCPATH_SHORT}\",\"keys\":[${KEYS}]},\"bucket\":\"${SRCBUCKETNAME}\",\"cloud_type\":\"${SRCCLOUDTYPE}\"},\"thread_num\":${THREAD_PER_TASK},\"enableKMS\":${ENABLE_KMS},\"description\":\"${DESC_PREFIX}_${ONE_LIST_FILE}\",\"dst_node\":{\"region\":\"${DSTREGION}\",\"ak\":\"${DSTAK}\",\"sk\":\"${DSTSK}\",\"object_key\":\"${DSTPATH_SHORT}\",\"bucket\":\"${DSTBUCKETNAME}\",\"cloud_type\":\"OTC\"}}" https://127.0.0.1:8443/maas/rest/v1/0000000000/objectstorage/task > ${ONE_LIST_FILE}_task.sh
	chmod 550 ${ONE_LIST_FILE}_task.sh
	if [ "${TABLE_FILE}" -ne "" ];then
		echo ${ONE_LIST_FILE}	${KEYS} >> $2
	fi
}

if [ "${ONE_LIST_FILE}" -eq "" ]; then
	help
else
	convert_list_to_task
fi
