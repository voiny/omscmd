#!/bin/bash

source ./conf.sh

LIST_FILE=$1
TYPE=$2
REMOVE_STRING=$3

function usage() {
	echo "[command] [LIST_FILE] [TYPE] [-REMOVE_STRING]"
}

if [[ "${TYPE}" == "" || "${LIST_FILE}" == "" ]]; then
	usage
	exit
fi

rm ${WORKSPACE}/converted_lists/ -rf
mkdir -p ${WORKSPACE}/converted_lists/ 

cp -f ${LIST_FILE} ${WORKSPACE}/list

if [ "${TYPE}" == "ossutil" ]; then
	./remove_line.sh first
	./remove_line.sh last
	./remove_line.sh last
fi

./split_list.sh
cd ${WORKSPACE}/lists/
LISTS=`ls`
COUNT=0

for LINE in ${LISTS}
do
	${ORIGINAL_DIRECTORY}/convert_list_format_from_${TYPE}.sh ${LINE} ${REMOVE_STRING} &
	let COUNT+=1
done

wait

cat ${WORKSPACE}/converted_lists/* > ${WORKSPACE}/converted_list
echo Converted ${COUNT} lists into standard fomrat.
echo Output path: ${WORKSPACE}/converted_list
cd ${ORIGINAL_DIRECTORY}

