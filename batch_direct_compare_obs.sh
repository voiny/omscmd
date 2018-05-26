#!/bin/bash

AK=$1
SK=$2
PAIRS=("cn-beijing,accesslog-ys"
"cn-beijing,oss-transfer"
"cn-beijing,test-biaozhun"
"cn-beijing,test-zhangrunshi"
"cn-beijing,test-zhangrunshi-1"
"cn-hangzhou,vmsdata"
"cn-beijing,ys-csupload"
"cn-beijing,ys-diandian"
"cn-beijing,ys-diandiantaobao"
"cn-beijing,ys-jsbc-test"
"cn-beijing,ys-onsite"
"cn-beijing,ys-public"
"cn-beijing,ys-shuchu"
"cn-beijing,ys-wechat"
"cn-beijing,ys-ytl"
"cn-beijing,ys-zhiyun"
"cn-beijing,ys-zhuanma"
"cn-hangzhou,yshz-public"
"cn-beijing,yunshi-cdn"
"cn-shanghai,zbtest-huadong2"
"cn-hangzhou,zcz-test"
)
WORK_THREAD_NUM=1
#Converted list path informat of timestamp(13) key size
LIST_PATH="/data/tmp/batch_download_increment_lists"
OUTPUT_PATH="/data/tmp/batch_direct_compare"

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
	echo ./direct_compare_obs.py --ak ${AK} --sk ${SK} -t ${WORK_THREAD_NUM} -e obs.myhwclouds.com -b ${BUCKET_NAME} -s ${LIST_PATH}/${BUCKET_NAME} -o ${OUTPUT_PATH}/${BUCKET_NAME}_direct_compare --cs --ct
	./direct_compare_obs.py --ak ${AK} --sk ${SK} -t ${WORK_THREAD_NUM} -e obs.myhwclouds.com -b ${BUCKET_NAME} -s ${LIST_PATH}/${BUCKET_NAME} -o ${OUTPUT_PATH}/${BUCKET_NAME}_direct_compare --cs --ct
done
IFS="$OLDIFS"

echo output path: ${OUTPUT_PATH}
