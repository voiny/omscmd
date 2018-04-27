#!/bin/bash

cd script
source ./env.sh
export PATH=$PATH:/usr/bin
cd ..
#echo $*
for i in $*; do
	bucket_name=`echo $i | awk -F, '{print $1;}'`
	region_id=`echo $i | awk -F, '{print $2;}'`
	dst_path="script-${bucket_name}"
	
	cp script ./${dst_path} -R
	
	sed "s/export SRCTOOL_ARG_LS=.*/export SRCTOOL_ARG_LS='ls -e ${region_id}.aliyuncs.com'/" -i ./${dst_path}/conf.sh
	sed "s/export SRCREGION=.*/export SRCREGION='${region_id}'/" -i ./${dst_path}/conf.sh
	sed "s/export SRCBUCKETNAME=.*/export SRCBUCKETNAME='${bucket_name}'/" -i ./${dst_path}/conf.sh
	sed "s/export NAME=.*/export NAME='omscmd-${bucket_name}'/" -i ./${dst_path}/conf.sh
	
	#cp script ./script-$i -R
done
