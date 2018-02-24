#!/bin/bash

source ./conf.sh

RESULT_PATH=${WORKSPACE}/sublists

SUBLISTS=`ls ${RESULT_PATH}`
SUBLISTS_COUNT=`ls ${RESULT_PATH} | wc -l`
let SUBLISTS_COUNT-=1

rm -rf ${WORKSPACE}/sublist_result

for SUBLIST in ${SUBLISTS}
do
	cat ${RESULT_PATH}/${SUBLIST} >> ${WORKSPACE}/sublist_result
done
