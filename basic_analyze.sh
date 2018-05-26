#!/bin/bash

ORIGINAL_DIRECTORY=$(cd $(dirname $0); pwd)
LISTPATH=$1
OUTPUT_FILE=$2

function usage() {
	echo "[command] [LISTPATH] [OUTPUT_FILE]" }

if [[ "${LISTPATH}" == "" || "${OUTPUT_FILE}" == "" ]]; then
	usage
	exit
fi


cd ${LISTPATH}
LIST=`ls ${LISTPATH}`
rm -rf ${OUTPUT_FILE}
for FILE in ${LIST}; do
	SIZE=`cat ${FILE} | awk '{sum+=$NF}END{print sum}'`
	if [ "${SIZE}" == "" ]; then
		SIZE=0
	fi
	OBJECT_COUNT=`cat ${FILE} | wc -l`
	if [ "${OBJECT_COUNT}" == "" ]; then
		OBJECT_COUNT=0
	fi
	echo ${FILE} ${OBJECT_COUNT} ${SIZE}>> ${OUTPUT_FILE}
done

cat ${OUTPUT_FILE}

cd ${ORIGINAL_DIRECTORY}
