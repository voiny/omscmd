#!/bin/bash

# AWS / Aliyun-OSS
export SRCCLOUDTYPE='Aliyun'
#SRCTOOL = aws / ossutil
export SRCTOOL='ossutil'
export SRCREGION='cn-beijing'
export SRCAK=''
export SRCSK=''
export SRCBUCKETNAME='bucketname'
export SRCPATH_SHORT='/xxx/'
export SRCPATH="oss://${SRCBUCKETNAME}${SRCPATH_SHORT}"
export DSTREGION='cn-north-1'
export DSTAK=''
export DSTSK=''
#DSTBUCKETNAME should not contain 's3://'
export DSTBUCKETNAME='bucketname'
#DSTPATH should not contain 's3://'
export DSTPATH_SHORT='xxx/'

export SERVER_ADDRESS="https://oms.myhuaweicloud.com/v1/{project_id}/objectstorage/task"
export NAME='omscmd'
export ENABLE_KMS='false'
export DESC_PREFIX='Migration_Project'
export WORKSPACE=/data/tmp/${NAME}
export OBJ_CNT_IN_SPLIT=1000000
export THREAD_PER_TASK=50
export DB_PWD='xxx'

export IAM_TOKEN=''

if [ "${ORIGINAL_DIRECTORY}" == "" ];then
	export ORIGINAL_DIRECTORY=$(pwd)
fi

if [ "${SRCTOOL}" == "ossutil" ];then
	export SRCPREFIX='oss'
	export SRCTOOL_ARG_RECURSIVE=''
	export SRCTOOL_ARG_NONRECURSIVE='-d'
	export SRCTOOL_ARG_LIMITED_NUM1='--limited-num 1'
	export SRCTOOL_ARG_LS='ls'
elif [ "${SRCTOOL}" == "aws" ];then
	export SRCPREFIX='s3'
	export SRCTOOL_ARG_RECURSIVE='--recursive'
	export SRCTOOL_ARG_NONRECURSIVE=''
	export SRCTOOL_ARG_LIMITED_NUM1=''
	export SRCTOOL_ARG_LS='s3 ls'
fi
