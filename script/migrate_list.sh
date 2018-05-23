#!/bin/bash
#Migrate objects according to given list

source ./conf.sh

function usage() {
	echo "[command] [LIST_FILE(customized2 format)]"
}

if [ "$1" == "" ]; then
	usage
	exit
fi

LIST_FILE=$1
/usr/bin/cp ${LIST_FILE} ${WORKSPACE}/list -f
./split_list.sh
./migrate_sublists.sh
