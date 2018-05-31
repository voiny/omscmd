#!/bin/bash

BUCKET_NAME=$1
PREFIX=$2
FILE_SIZE=$3
FILE_NUM=$4
TMP_FILE=/tmp/${PREFIX}_tmp

function usage() {
	echo "[command] [BUCKET_NAME] [PREFIX] [FILE_SIZE(KBytes)] [FILE_NUM]"
}

if [[ "${BUCKET_NAME}" == "" || "${PREFIX}" == "" || "${FILE_SIZE}" == "" || "${FILE_NUM}" == "" ]];then
	usage
	exit
fi


echo > ${TMP_FILE}
SEQ=`seq 2 ${FILE_SIZE}`
for i in ${SEQ}
do
	echo 0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789abcdefghijklmnopqrstvuwx >> ${TMP_FILE}
done

SEQ=`seq 1 ${FILE_NUM}`
let "SEQ/=100"
for i in ${SEQ}
do
	for j in {0..99}
	do
		let "k+=${j}"
		echo qshell fput ${BUCKET_NAME} ${PREFIX}_${i}_${j} ${TMP_FILE}
		qshell fput ${BUCKET_NAME} ${PREFIX}_${i}_${j} ${TMP_FILE} &
	done
	wait
done


echo Done.
