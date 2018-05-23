#!/bin/bash
#Migrate objects according to given sublists

source ./conf.sh

rm -rf ${WORKSPACE}/migration
mkdir -p ${WORKSPACE}/migration
cd ${WORKSPACE}/lists/
LISTS=`ls`
COUNT=0

for LINE in ${LISTS}
do
	echo Creating migration task: ${LINE}
	${ORIGINAL_DIRECTORY}/migrate_sublist.sh ${LINE} ${LINE} &
	let COUNT+=1
done

wait
echo Migration finished.
