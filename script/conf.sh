#!/bin/bash

export SRCCLOUDTYPE='AWS'
export SRCREGION='cn-north-1'
export SRCAK='AKIAOAEPUWBDIB22BTYQ'
export SRCSK='AF6tqTXCzmMPEHSjgaXu0HbZA6K2tnLuKqTKJF1T'
export SRCBUCKETNAME='image-center-test'
export SRCPATH_SHORT='/2017-1/'
export SRCPATH="s3://${SRCBUCKETNAME}${SRCPATH_SHORT}"
export DSTREGION='cn-north-1'
export DSTAK='SQ9AJNY8IHPK13L6EHAZ'
export DSTSK='1de63kHtWbj4YEQe3dFSJjlx8sbMKEVJTOomdPxl'
#DSTBUCKETNAME should not contain 's3://'
export DSTBUCKETNAME='1-1201liuchang-maas'
#DSTPATH should not contain 's3://'
export DSTPATH_SHORT='speedtest/newtest2/'

#SRCTOOL = aws s3 / s3cmd
export SRCTOOL='aws s3'
export NAME='omscmd'
export ENABLE_KMS='true'
export DESC_PREFIX='Migration_Project'
export WORKSPACE=/tmp/${NAME}
export OBJ_CNT_IN_SPLIT=10
export THREAD_PER_TASK=50
export DB_PWD='Maasobs@123'
if [ "${ORIGINAL_DIRECTORY}" == "" ];then
	export ORIGINAL_DIRECTORY=$(pwd)
fi
