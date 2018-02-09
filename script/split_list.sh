#!/bin/bash

source ./conf.sh

cd ${WORKSPACE}
rm -rf list_*
rm -rf lists
split -l ${OBJ_CNT_IN_SPLIT} ${WORKSPACE}/list list_
mkdir -p ${WORKSPACE}/lists
mv list_* ${WORKSPACE}/lists/
cd ${WORKSPACE}/lists
echo Lists:
ls
COUNT=`ls -l | wc -l`
let COUNT-=1
if [ ${COUNT} -eq -1 ];then
	let COUNT=0
fi
echo Count of Lists: ${COUNT}
