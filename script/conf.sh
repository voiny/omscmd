#!/bin/bash

export SRCCLOUDTYPE='AWS'
export SRCREGION='cn-north-1'
export SRCAK=''
export SRCSK=''
export SRCBUCKETNAME=''
export SRCPATH_SHORT=''
export SRCPATH="s3://${SRCBUCKETNAME}${SRCPATH_SHORT}"
export DSTREGION='cn-north-1'
export DSTAK=''
export DSTSK=''
#DSTBUCKETNAME should not contain 's3://'
export DSTBUCKETNAME=''
#DSTPATH should not contain 's3://'
export DSTPATH_SHORT=''

#SRCTOOL = aws s3 / s3cmd
export SRCTOOL='aws s3'
export NAME='omscmd'
export ENABLE_KMS='true'
export DESC_PREFIX='Migration_Project'
export WORKSPACE=/tmp/${NAME}
export OBJ_CNT_IN_SPLIT=10
export THREAD_PER_TASK=50
export DB_PWD=''
if [ "${ORIGINAL_DIRECTORY}" == "" ];then
	export ORIGINAL_DIRECTORY=$(pwd)
fi
