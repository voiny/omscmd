#!/bin/bash

source ./conf.sh

TYPE=$1
REMOVE_STRING=$2

rm ${WORKSPACE}/converted_lists/ -rf
mkdir -p ${WORKSPACE}/converted_lists/ 

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
cd ${ORIGINAL_DIRECTORY}
