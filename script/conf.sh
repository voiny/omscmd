#!/bin/bash

export SRCCLOUDTYPE='AWS'
export SRCREGION='xx-xxxx-1'
export SRCAK='xxx'
export SRCSK='xxx'
export SRCBUCKETNAME='xxx'
export SRCPATH_SHORT='/xxx/'
export SRCPATH="s3://${SRCBUCKETNAME}${SRCPATH_SHORT}"
export DSTREGION='xx-xxx-1'
export DSTAK='xxx'
export DSTSK='xxx'
#DSTBUCKETNAME should not contain 's3://'
export DSTBUCKETNAME='xxx'
#DSTPATH should not contain 's3://'
export DSTPATH_SHORT='xxx/xxx/'

#SRCTOOL = aws s3 / s3cmd
export SRCTOOL='aws s3'
export NAME='omscmd'
export ENABLE_KMS='true'
export DESC_PREFIX='Migration_Project'
export WORKSPACE=/tmp/${NAME}
export OBJ_CNT_IN_SPLIT=10
export THREAD_PER_TASK=50
export DB_PWD='xxx'
if [ "${ORIGINAL_DIRECTORY}" == "" ];then
	export ORIGINAL_DIRECTORY=$(pwd)
fi
