#!/bin/bash

# AWS / Aliyun / Qiniu
export SRCCLOUDTYPE='Aliyun'
#SRCTOOL = aws / ossutil / qshell
export SRCTOOL='ossutil'
#for OSS cn-beijing is OK, oss-cn-beijing is NOK
export SRCREGION='cn-beijing'
export SRCAK=''
export SRCSK=''
#export SRCAK='LTAI7JYINLrQcd12'
#export SRCSK='uJyVHxEwVN4TKnowLxcyAQ82gsMlM2'
export SRCBUCKETNAME='api-auto-test'
export SRCPATH_SHORT='/'
#export SRCPATH_SHORT='/xxx/'
export SRCPATH="oss://${SRCBUCKETNAME}${SRCPATH_SHORT}"
export DSTREGION='cn-north-1'
export DSTAK=''
export DSTSK=''
#DSTBUCKETNAME should not contain 's3://'
export DSTBUCKETNAME=''
#DSTPATH should not contain 's3://'
#export DSTPATH_SHORT='xxx/' (set '/' for root)
export DSTPATH_SHORT='/'

#export SERVER_ADDRESS="https://127.0.0.1:8099/v1/0000000000"
export DOMAIN_NAME=''
export TENANT_NAME=''
export TENANT_PASSWORD=''
export PROJECT_ID=''
export SERVER_ADDRESS="https://oms.myhuaweicloud.com/v1/${PROJECT_ID}"
export NAME='omscmd'
export ENABLE_KMS='false'
export DESC_PREFIX='Task'
export WORKSPACE=/data/tmp/${NAME}
export OBJ_CNT_IN_SPLIT=50
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
