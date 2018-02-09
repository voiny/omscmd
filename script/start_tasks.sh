#!/bin/bash

source ./conf.sh

cd ${WORKSPACE}/tasks

TASKS_FILES=`ls`
TASK_COUNT=`ls -l | wc -l`
COUNTER=0
let TASK_COUNT-=1

for TASKFILE in ${TASKS_FILES}
do
	let COUNTER+=1
	echo TASK ${COUNTER} ${TASKFILE} is starting:
	./${TASKFILE}
	echo
done

echo Started ${TASK_COUNT} tasks.
