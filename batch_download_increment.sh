#!/bin/bash

AK=$1
SK=$2
PAIRS=("oss-cn-beijing,accesslog-ys"
"oss-cn-beijing,oss-transfer"
)
SEPARATE_TIME="2018-05-20 00:00:00"
ENDPOINT_URL_POSTFIX=".aliyuncs.com"
SECTION_SIZE=10000
WORK_THREAD_NUM=100
#Converted list path informat of timestamp(13) key size
LIST_PATH="/data/conv_oss"
OUTPUT_PATH="/data/tmp/batch_download_increment_lists"

function usage() {
	echo "edit parameters in this command first."
	echo "[command] [ak] [sk]"
}

if [[ "${AK}" == "" || "${SK}" == "" ]]; then
	usage
	exit
fi

rm -rf ${OUTPUT_PATH}
mkdir -p ${OUTPUT_PATH}
OLDIFS="$IFS"
IFS=$'\n'
for LINE in ${PAIRS[@]}
do 
	REGION=`echo ${LINE} | awk -F',' '{print $1}'`
	BUCKET_NAME=`echo ${LINE} | awk -F',' '{print $2}'`
	echo ./download_increment_oss.py --ak ${AK} --sk ${SK} --separate_time \"${SEPARATE_TIME}\" --section_size ${SECTION_SIZE} -t ${WORK_THREAD_NUM} -e ${REGION}${ENDPOINT_URL_POSTFIX} -b ${BUCKET_NAME} -s ${LIST_PATH}/${BUCKET_NAME} -o ${OUTPUT_PATH}/${BUCKET_NAME}_increment
	./download_increment_oss.py --ak ${AK} --sk ${SK} --separate_time "${SEPARATE_TIME}" --section_size ${SECTION_SIZE} --t ${WORK_THREAD_NUM} -e ${REGION}${ENDPOINT_URL_POSTFIX} -b ${BUCKET_NAME} -s ${LIST_PATH}/${BUCKET_NAME} -o ${OUTPUT_PATH}/${BUCKET_NAME}_increment
done
IFS="$OLDIFS"

echo separate time: ${SEPARATE_TIME}, output path: ${OUTPUT_PATH}
