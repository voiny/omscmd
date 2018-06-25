#!/bin/bash
#Migrate objects according to given sublists

source ./conf.sh

cd ${WORKSPACE}/lists/
LISTS=`ls`
COUNT=0

for LINE in ${LISTS}
do
	echo Creating removin task: ${LINE}
	${ORIGINAL_DIRECTORY}/rm_sublist.sh ${LINE} ${LINE} &
	let COUNT+=1
done

wait
echo Removing finished.
