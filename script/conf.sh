#!/bin/bash

# AWS / OSS
export SRCCLOUDTYPE='OSS'
#SRCTOOL = aws / ossutil
export SRCTOOL='ossutil'
export SRCREGION='oss-cn-hangzhou.aliyuncs.com'
export SRCAK='xxx'
export SRCSK='xxx'
export SRCBUCKETNAME='xxx'
export SRCPATH_SHORT='/xxx/'
export SRCPATH="oss://${SRCBUCKETNAME}${SRCPATH_SHORT}"
export DSTREGION='xx-xxx-1'
export DSTAK='xxx'
export DSTSK='xxx'
#DSTBUCKETNAME should not contain 's3://'
export DSTBUCKETNAME='xxx'
#DSTPATH should not contain 's3://'
export DSTPATH_SHORT='xxx/xxx/'

export NAME='omscmd'
export ENABLE_KMS='false'
export DESC_PREFIX='Migration_Project'
export WORKSPACE=/tmp/${NAME}
export OBJ_CNT_IN_SPLIT=1000
export THREAD_PER_TASK=50
export DB_PWD='xxx'
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
