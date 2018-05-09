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
	dst_file="/data/result-${bucket_name}"
	rm -rf ${dst_file}
	ossutil -e ${region_id}.aliyuncs.com ls oss://${bucket_name}/ | tee ${dst_file} &
done

wait
echo All tasks are down.
