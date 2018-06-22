#!/bin/bash

cd script
source ./env.sh
export PATH=$PATH:/usr/bin
cd ..
OUTPUT_PATH=$1
BUCKET_LIST=$2

function usage()
{
	echo "[command] [OUTPUT_PATH:/data/list_result/] [BUCKET_LIST]"
	echo "[command] /data/list_result/ bkt1,bkt2,bkt3"
}

if [[ "${OUTPUT_PATH}" == "" || "$BUCKET_LIST" == "" ]];then
	usage
	exit
fi

mkdir -p ${OUTPUT_PATH}
LIST=$(echo $BUCKET_LIST|tr "," "\n")

for i in ${LIST}; do
	bucket_name=$i
	dst_file=${OUTPUT_PATH}/${bucket_name}
	rm -rf ${dst_file}
	bcecmd bos ls ${bucket_name} --all --recursive > ${dst_file} &
done

echo "watch ${OUTPUT_PATH} for querying pregress"
wait
echo All tasks are down.
