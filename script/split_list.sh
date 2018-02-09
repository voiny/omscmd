#!/bin/bash

source ./conf.sh

cd ${WORKSPACE}
rm -rf list_*
rm -rf lists
split -l ${OBJ_CNT_IN_SPLIT} ${WORKSPACE}/list list_
mkdir -p ${WORKSPACE}/lists
mv list_* ${WORKSPACE}/lists/
cd ${WORKSPACE}
ls
ls -l | wc -l
