#!/bin/bash

if [ "${ORIGINAL_DIRECTORY}" != "" ]; then
	source ${ORIGINAL_DIRECTORY}/conf.sh
else
	source ./conf.sh
fi

ONE_LIST_FILE=$1
TASK_NAME=$2
DOWNLOAD_PATH=${WORKSPACE}/migration/download_tmp
DOWNLOAD_LOG_PATH=${WORKSPACE}/migration/download_log
UPLOAD_LOG_PATH=${WORKSPACE}/migration/upload_log

mkdir -p ${DOWNLOAD_LOG_PATH}
mkdir -p ${DOWNLOAD_PATH}
mkdir -p ${UPLOAD_LOG_PATH}

rm -rf ${DOWNLOAD_LOG_PATH}/${TASK_NAME}_download.log
rm -rf ${DOWNLOAD_PATH}/${TASK_NAME}
rm -rf ${UPLOAD_LOG_PATH}/${TASK_NAME}_upload.log

function help() {
	echo Usage: ./migrate_list list_file
}

function migrate() {
	LIST=`cat ${ONE_LIST_FILE}`
	KEYS=''
	for LINE in ${LIST}
	do
		migrate_command ${LINE} ${DOWNLOAD_PATH}/${TASK_NAME}
	done
}

function migrate_command() {
	LINE=$1
	TMP_FILE=$2
	rm -rf ${TMP_FILE}
	echo TASK ${TASK_NAME} is migrating ${LINE} ...
	if [ "${SRCTOOL}" == "ossutil" ];then
		echo ossutil --endpoint=oss-${SRCREGION}.aliyuncs.com --access-key-id=${SRCAK} --access-key-secret=${SRCSK} cp oss://${SRCBUCKETNAME}${SRCPATH_SHORT}${LINE} ${TMP_FILE}
		ossutil --endpoint=oss-${SRCREGION}.aliyuncs.com --access-key-id=${SRCAK} --access-key-secret=${SRCSK} cp oss://${SRCBUCKETNAME}${SRCPATH_SHORT}${LINE} ${TMP_FILE} >> ${DOWNLOAD_LOG_PATH}/${TASK_NAME}_download.log
	elif [ "${SRCTOOL}" == "aws" ];then
		echo Not supported
		exit
	fi
	echo aws --endpoint-url=http://obs.myhwclouds.com --region=${DSTREGION} --profile=dst s3 cp ${TMP_FILE} s3://${DSTBUCKETNAME}/${DSTPATH_SHORT}${LINE}
	aws --endpoint-url=http://obs.myhwclouds.com --region=${DSTREGION} --profile=dst s3 cp ${TMP_FILE} s3://${DSTBUCKETNAME}/${DSTPATH_SHORT}${LINE} >> ${UPLOAD_LOG_PATH}/${TASK_NAME}_upload.log
}

if [[ "${ONE_LIST_FILE}" == "" || "${TASK_NAME}" == "" ]]; then
	help
else
	migrate
fi
