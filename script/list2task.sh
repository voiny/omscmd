#!/bin/bash

if [ "${ORIGINAL_DIRECTORY}" != "" ]; then
	source ${ORIGINAL_DIRECTORY}/conf.sh
else
	source ./conf.sh
fi

ONE_LIST_FILE=$1
TABLE_FILE=$2

function help() {
	echo Usage: ./list2task.sh list_file
}

function convert_list_to_task() {
	LIST=`cat ${ONE_LIST_FILE}`
	KEYS=''
	OLDIFS="${IFS}"
	IFS=$'\n'
	for LINE in ${LIST}
	do
		KEYS=\"${LINE}\"
		break
	done
	for LINE in ${LIST}
	do
		if [ "\"${LINE}\"" == "${KEYS}" ]; then
			continue	
		fi
		KEYS=${KEYS},\"${LINE}\"
	done
	echo "#!/bin/bash" >${ONE_LIST_FILE}_task.sh
	echo "" >>${ONE_LIST_FILE}_task.sh
	echo "PARAM1=\$1">>${ONE_LIST_FILE}_task.sh
	echo "PARAM2=\$2">>${ONE_LIST_FILE}_task.sh
	echo "function start() {">>${ONE_LIST_FILE}_task.sh
	echo "curl -H 'Content-Type:application/json' -H 'X-Auth-Token:${IAM_TOKEN}' --insecure -X POST --data '{\"src_node\":{\"region\":\"${SRCREGION}\",\"ak\":\"${SRCAK}\",\"sk\":\"${SRCSK}\",\"object_key\":{\"path\":\"${SRCPATH_SHORT}\",\"keys\":[${KEYS}]},\"bucket\":\"${SRCBUCKETNAME}\",\"cloud_type\":\"${SRCCLOUDTYPE}\"},\"thread_num\":${THREAD_PER_TASK},\"enableKMS\":${ENABLE_KMS},\"description\":\"${DESC_PREFIX}_${ONE_LIST_FILE}\",\"dst_node\":{\"region\":\"${DSTREGION}\",\"ak\":\"${DSTAK}\",\"sk\":\"${DSTSK}\",\"object_key\":\"${DSTPATH_SHORT}\",\"bucket\":\"${DSTBUCKETNAME}\",\"cloud_type\":\"OTC\"}}' ${SERVER_ADDRESS}/objectstorage/task">> ${ONE_LIST_FILE}_task.sh
	echo "}" >> ${ONE_LIST_FILE}_task.sh
	echo "function stop() {" >> ${ONE_LIST_FILE}_task.sh
	echo "curl -H 'Content-Type:application/json' -H 'X-Auth-Token:${IAM_TOKEN}' --insecure -X PUT --data '{\"operation\":\"stop\"}' ${SERVER_ADDRESS}/objectstorage/task/\${PARAM2}" >> ${ONE_LIST_FILE}_task.sh
	echo "}">> ${ONE_LIST_FILE}_task.sh
	echo "function resume() {" >> ${ONE_LIST_FILE}_task.sh
	echo "curl -H 'Content-Type:application/json' -H 'X-Auth-Token:' --insecure -X PUT --data '{\"operation\":\"start\",\"source_ak\":\"${SRCAK}\",\"source_sk\":\"${SRCSK}\",\"target_ak\":\"${DSTAK}\",\"target_sk\":\"${DSTSK}\"}' ${SERVER_ADDRESS}/objectstorage/task/\${PARAM2}">> ${ONE_LIST_FILE}_task.sh
	echo "}">> ${ONE_LIST_FILE}_task.sh
	echo "function status() {">> ${ONE_LIST_FILE}_task.sh
	echo "	TASK_STATUS=\`curl -H Content-Type:application/json -H X-Auth-Token: --insecure -s -X GET ${SERVER_ADDRESS}/objectstorage/task/\${PARAM2}|jq \".status\"\`">> ${ONE_LIST_FILE}_task.sh
	echo "	echo \"\${TASK_STATUS}\"">> ${ONE_LIST_FILE}_task.sh
	echo "}">> ${ONE_LIST_FILE}_task.sh
	echo "if [ \"\${PARAM1}\" == \"start\" ]; then" >> ${ONE_LIST_FILE}_task.sh
	echo "	start">> ${ONE_LIST_FILE}_task.sh
	echo "elif [ \"\${PARAM1}\" == \"stop\" ];then" >> ${ONE_LIST_FILE}_task.sh
	echo "	stop">> ${ONE_LIST_FILE}_task.sh
	echo "elif [ \"\${PARAM1}\" == \"resume\" ];then" >> ${ONE_LIST_FILE}_task.sh
	echo "	resume">> ${ONE_LIST_FILE}_task.sh
	echo "elif [ \"\${PARAM1}\" == \"status\" ];then" >> ${ONE_LIST_FILE}_task.sh
	echo "	status">> ${ONE_LIST_FILE}_task.sh
	echo "else">> ${ONE_LIST_FILE}_task.sh
	echo "echo \"[command] [action(start/stop/resume/status)] [taskid]\"">> ${ONE_LIST_FILE}_task.sh
	echo "fi" >> ${ONE_LIST_FILE}_task.sh
	
	chmod 550 ${ONE_LIST_FILE}_task.sh
	if [ "${TABLE_FILE}" != "" ];then
		echo ${ONE_LIST_FILE}	${KEYS} >> ${TABLE_FILE}
	fi
	IFS="${OLDIFS}"
}


if [ "${ONE_LIST_FILE}" == "" ]; then
	help
else
	convert_list_to_task
fi
