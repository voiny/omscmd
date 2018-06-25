#!/bin/bash

if [ "${ORIGINAL_DIRECTORY}" != "" ]; then
	source ${ORIGINAL_DIRECTORY}/conf.sh
else
	source ./conf.sh
fi

ONE_LIST_FILE=$1
TASK_NAME=$2

function help() {
	echo Usage: ./rm_list list_file
}

function do_remove() {
	OLDIFS="${IFS}"
	IFS=$'\n'
	LIST=`cat ${ONE_LIST_FILE}`
	KEYS=''
	for LINE in ${LIST}
	do
		remove_command "${LINE}"
	done
	IFS="${OLDIFS}"
}

function remove_command() {
	LINE="$*"
	echo TASK ${TASK_NAME} is removing ${LINE} ...
	echo aws --endpoint-url=http://obs.${DSTREGION}.myhwclouds.com --region=${DSTREGION} --profile=dst s3 rm "s3://${DSTBUCKETNAME}${DSTPATH_SHORT}${LINE}"
	aws --endpoint-url=http://obs.${DSTREGION}.myhwclouds.com --region=${DSTREGION} --profile=dst s3 rm "s3://${DSTBUCKETNAME}${DSTPATH_SHORT}${LINE}"
}

if [[ "${ONE_LIST_FILE}" == "" || "${TASK_NAME}" == "" ]]; then
	help
else
	do_remove
fi
