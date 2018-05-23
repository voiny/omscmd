#!/bin/bash

ORIGINAL_DIRECTORY=$(cd $(dirname $0); pwd)
LISTPATH=$1


cd ${LISTPATH}
LIST=`ls`
rm -rf ${ORIGINAL_DIRECTORY}/result.txt
for FILE in ${LIST}; do
	SIZE=`cat ${FILE} | awk '{sum+=$3}END{print sum}'`
	if [ "${SIZE}" == "" ]; then
		SIZE=0
	fi
	OBJECT_COUNT=`cat ${FILE} | wc -l`
	if [ "${OBJECT_COUNT}" == "" ]; then
		OBJECT_COUNT=0
	fi
	echo ${FILE} ${OBJECT_COUNT} ${SIZE}>> ${ORIGINAL_DIRECTORY}/result.txt
done

cat ${ORIGINAL_DIRECTORY}/result.txt

cd ${ORIGINAL_DIRECTORY}
