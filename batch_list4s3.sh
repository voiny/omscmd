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

export PYTHONIOENCODING=UTF-8

mkdir -p ${OUTPUT_PATH}
for i in $*; do
	bucket_name=`echo $i | awk -F, '{print $1;}'`
	region_id=`echo $i | awk -F, '{print $2;}'`
	dst_file="${OUTPUT_PATH}/result-${bucket_name}"
	rm -rf ${dst_file}
	aws --endpoint-url=http://s3.cn-north-1.amazonaws.com.cn --region=${region_id} s3 ls s3://${bucket_name}/ --recursive | tee ${dst_file} &
done

wait
echo All tasks are down.
