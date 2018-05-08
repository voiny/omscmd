#!/bin/bash

cd script
source ./env.sh
export PATH=$PATH:/usr/bin
cd ..
mkdir -p /data/tmp-result
for i in $*; do
	bucket_name=`echo $i | awk -F, '{print $1;}'`
	region_id=`echo $i | awk -F, '{print $2;}'`
	dst_file="/data/tmp-result/result-${bucket_name}"
	rm -rf ${dst_file}
	aws --endpoint-url=http://s3.cn-north-1.amazonaws.com.cn --region=${region_id} s3 ls s3://${bucket_name}/ --recursive | tee ${dst_file} &
done

wait
echo All tasks are down.
