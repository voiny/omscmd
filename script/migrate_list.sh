#!/bin/bash
#Migrate objects according to given list

source ./conf.sh

function usage() {
	echo "[command] [LIST_FILE] [TYPE=awscli/ossutil/qshell/osf(oms standard format)/pol(purified object list)] [-AMAZON_CN_REGION=cn/(empty for international regions)]"
}

if [[ "$1" == "" || "$2" == "" ]]; then
	usage
	exit
fi

LIST_FILE=$1
TYPE=$2
export AMAZON_CN_REGION=""
if [ "$3" == "cn" ]; then
	export AMAZON_CN_REGION="cn"
fi
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
	qshell)
		./convert_list_format.sh ${LIST_FILE} qshell
	;;
	pol)
	;;
	*)
	;;
esac

/usr/bin/mv ${WORKSPACE}/converted_list ${WORKSPACE}/list -f
./split_list.sh
./migrate_sublists.sh
