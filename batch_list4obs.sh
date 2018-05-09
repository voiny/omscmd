#!/bin/bash

cd script
source ./env.sh
export PATH=$PATH:/usr/bin
cd ..
OUTPUT_PATH=$1

function usage()
{
	echo "[command] [OUTPUT_PATH:/data/list_result/]"
}

if [ "${OUTPUT_PATH}" == "" ];then
	usage
	exit
fi

mkdir -p ${OUTPUT_PATH}
for i in $*; do
	bucket_name=`echo $i | awk -F, '{print $1;}'`
	region_id=`echo $i | awk -F, '{print $2;}'`
	dst_file="${OUTPUT_PATH}/result-${bucket_name}"
	rm -rf ${dst_file}
	aws --endpoint-url=http://obs.myhwclouds.com --region=${region_id} s3 ls s3://${bucket_name}/ --recursive | tee ${dst_file} &
done

wait
echo All tasks are down.