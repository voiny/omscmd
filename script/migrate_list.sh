#!/bin/bash
#Migrate objects according to given list

source ./conf.sh

function usage() {
	echo "[command] [LIST_FILE] [TYPE=awscli/ossutil/osf(oms standard format)/pol(purified object list)]"
}

if [[ "$1" == "" || "$2" == "" ]]; then
	usage
	exit
fi

LIST_FILE=$1
TYPE=$2
/usr/bin/cp ${LIST_FILE} ${WORKSPACE}/list -f

case ${TYPE} in
	osf)
		./convert_list_format.sh ${LIST_FILE} osf
	;;
	ossutil)
		./convert_list_format.sh ${LIST_FILE} ossutil oss://
	;;
	awscli)
		./convert_list_format.sh ${LIST_FILE} awscli
	;;
	pol)
	;;
	*)
	;;
esac

/usr/bin/mv ${WORKSPACE}/converted_list ${WORKSPACE}/list -f
./split_list.sh
./migrate_sublists.sh
