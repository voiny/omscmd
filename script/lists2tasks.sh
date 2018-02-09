#!/bin/bash

source ./conf.sh

cd ${WORKSPACE}/lists/
rm -rf ${WORKSPACE}/tasktable
LISTS=`ls`
COUNT=0

for LINE in ${LISTS}
do
	echo converting task: ${LINE}
	${ORIGINAL_DIRECTORY}/list2task.sh ${LINE} ${WORKSPACE}/tasktable
	let COUNT+=1
done

rm -rf ${WORKSPACE}/tasks/
mkdir -p ${WORKSPACE}/tasks
mv ${WORKSPACE}/lists/*_task.sh ${WORKSPACE}/tasks/
echo Converted ${COUNT} lists into tasks.
