#!/bin/bash

source ./conf.sh

cd ${WORKSPACE}/lists/
rm -rf ${WORKSPACE}/tasktable
LISTS=`ls`

for LINE in ${LISTS}
do
	echo converting task: ${LINE}
	${ORIGINAL_DIRECTORY}/list2task.sh ${LINE} ${WORKSPACE}/tasktable
done

rm -rf ${WORKSPACE}/tasks/
mkdir -p ${WORKSPACE}/tasks
mv ${WORKSPACE}/lists/*_task.sh ${WORKSPACE}/tasks/
