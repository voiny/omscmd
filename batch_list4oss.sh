#!/bin/bash

cd script
source ./env.sh
export PATH=$PATH:/usr/bin
cd ..
for i in $*; do
	bucket_name=`echo $i | awk -F, '{print $1;}'`
	region_id=`echo $i | awk -F, '{print $2;}'`
	dst_file="/data/result-${bucket_name}"
	rm -rf ${dst_file}
	ossutil -e ${region_id}.aliyuncs.com ls oss://${bucket_name}/ | tee ${dst_file} &
done

wait
echo All tasks are down.
