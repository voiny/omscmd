#!/bin/bash
#Migrate objects according to given list

source ./conf.sh

rm -rf ${WORKSPACE}/migration
mkdir -p ${WORKSPACE}/migration
LIST_FILE=$1
/usr/bin/cp ${LIST_FILE} ${WORKSPACE}/list -f
./split_list.sh
./migrate_sublists.sh
