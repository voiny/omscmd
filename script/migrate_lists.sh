#!/bin/bash
#Migrate objects according to given list

source ./conf.sh

rm -rf ${WORKSPACE}/migration
mkdir -p ${WORKSPACE}/migration
cd ${WORKSPACE}/lists/
LISTS=`ls`
COUNT=0

for LINE in ${LISTS}
do
	echo Crating migration task: ${LINE}
	${ORIGINAL_DIRECTORY}/migrate_list.sh ${LINE} ${LINE} &
	let COUNT+=1
done

wait
echo Migration finished.
