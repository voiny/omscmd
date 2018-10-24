#!/bin/bash

ORIGINAL_DIRECTORY=$(cd $(dirname $0); pwd)
LISTPATH=$1
FORMAT=$2
OUTPUT_FILE=$3

function usage() {
	echo "[command] [LISTPATH] [FORMAT(osf/olf)] [OUTPUT_FILE]"
}

if [[ "${LISTPATH}" == "" || "${OUTPUT_FILE}" == "" || "${FORMAT}" == "" ]]; then
	usage
	exit
fi

cd ${LISTPATH}
LIST=`ls ${LISTPATH}`
rm -rf ${OUTPUT_FILE}
if [ -d "${LISTPATH}" ]; then
	if [ "${FORMAT}" == "osf" ]; then
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
	elif [ "${FORMAT}" == "olf" ]; then
		for FILE in ${LIST}; do
			SIZE=`cat ${FILE} | awk '{sum+=$3}END{print sum}'`
			if [ "${SIZE}" == "" ]; then
				SIZE=0
			fi
			OBJECT_COUNT=`cat ${FILE} | wc -l`
			if [ "${OBJECT_COUNT}" == "" ]; then
				OBJECT_COUNT=0
			fi
			echo ${FILE} ${OBJECT_COUNT} ${SIZE}>> ${OUTPUT_FILE}
		done
	else
		usage
		exit
	fi
else
	if [ "${FORMAT}" == "osf" ]; then
		SIZE=`cat ${LISTPATH} | awk '{sum+=$NF}END{print sum}'`
		if [ "${SIZE}" == "" ]; then
			SIZE=0
		fi
		OBJECT_COUNT=`cat ${LISTPATH} | wc -l`
		if [ "${OBJECT_COUNT}" == "" ]; then
			OBJECT_COUNT=0
		fi
		echo ${LISTPATH} ${OBJECT_COUNT} ${SIZE}>> ${OUTPUT_FILE}
	elif [ "${FORMAT}" == "olf" ]; then
		SIZE=`cat ${LISTPATH} | awk '{sum+=$3}END{print sum}'`
		if [ "${SIZE}" == "" ]; then
			SIZE=0
		fi
		OBJECT_COUNT=`cat ${LISTPATH} | wc -l`
		if [ "${OBJECT_COUNT}" == "" ]; then
			OBJECT_COUNT=0
		fi
		echo ${LISTPATH} ${OBJECT_COUNT} ${SIZE}>> ${OUTPUT_FILE}
	else
		usage
		exit
	fi
fi

cat ${OUTPUT_FILE}

cd ${ORIGINAL_DIRECTORY}
