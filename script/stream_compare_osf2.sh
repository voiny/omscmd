#!/bin/bash

SRCLIST=""
THREADNUM=4
DSTREGION="cn-north-1"
DSTBUCKETNAME='10002'
WORKSPACE="/data/tmp/stream_compare_$$"

function download()
{
	thread_name=$1
	line=$2
	download_file_full_path=${WORKSPACE}/${thread_name}_download
	#echo aws --endpoint-url=http://obs.myhwclouds.com --region=${DSTREGION} --profile=dst s3 cp ${TMP_FILE} "s3://${DSTBUCKETNAME}${DSTPATH_SHORT}${LINE}"
	rm -rf ${download_file_full_path}
	i=0
	while [[ ! -f "${download_file_full_path}" && $i -le 10 ]]
	do
		aws --endpoint-url=http://obs.${DSTREGION}.myhwclouds.com --region=${DSTREGION} --profile=dst s3 cp "s3://${DSTBUCKETNAME}/${line}" "${download_file_full_path}" > /dev/null
		let i+=1
	done
	if [ $i > 10 ]; then
		echo 0
	else
		echo 1
	fi
}

function exist_on_obs()
{
	thread_name=$1
	line=$2
	result=""
	i=0
	while [[ ! ("${result}" =~ "$line") && $i -le 10 ]]
	do
		result=`aws --endpoint-url=http://obs.${DSTREGION}.myhwclouds.com --region=${DSTREGION} --profile=dst s3 ls \"s3://${DSTBUCKETNAME}/${line}\"`
		let i+=1
	done
	if [ $result =~ $line ]; then
		echo 1
	else
		echo 0
	fi
}

function verify_hash()
{
	thread_name=$1
	list=$2
	key=`echo $list | awk '{for (i=2;i<NF-2;i++) printf("%s ", $i); printf("%s", NF)}'`
	hash_in_list=`echo $list | awk '{printf("%s", NF);}'`
	local_file_hash=""
	result=0
	if [[ "exist_on_obs \"$thread_name\" \"$key\"" == "1" ]]; then
		if [[ "download \"$thread_name\" \"$key\"" == "1" ]]; then
			download_file_full_path=${WORKSPACE}/${thread_name}_download
			local_file_hash=`qshell qetag "${download_file_full_path}"`
			if [[ "${local_file_hash}" == "${hash_in_list}" ]]; then
				result=1
			fi
		fi
	fi
	if [ "${result}" == "0" ];then
		echo "$key $hash_in_list $local_file_hash" >> ${WORKSPACE}/${DSTBUCKET}-failure.log
		echo "FAILED $key $hash_in_list $local_file_hash"
	else
		echo "OK $key $hash_in_list $local_file_hash"
	fi
	echo >&5
}

function dispatch()
{
	thread_name=$1
	list=$2
	mkfifo ${WORKSPACE}/fifo
	exec 5<>${WORKSPACE}/fifo
	rm -rf ${WORKSPACE}/fifo
	
	for ((i=1;i<=${TRHEADNUM};i++))
	do
		echo ;
	done >&5

	cat $list | while read line
	do
		read -u5
		{
			verify_hash "$thread_name" "$line"
		} &
	done
	wait
	exec 5>&-
}

function usage()
{
	echo "[command] SRCLIST THREADNUM DSTREGION DSTBUCKET"
}

function main()
{
	if [[ "$4" == "" ]]; then
		usage
		exit
	fi
	
	[[ "$1" != "" ]] && SRCLIST=$1
	[[ "$2" != "" ]] && THREADNUM=$2
	[[ "$3" != "" ]] && DSTREGION=$3
	[[ "$4" != "" ]] && DSTBUCKET=$4
	
	WORKSPACE="/data/tmp/stream_compare_${DSTUBKCET}_$$"
	rm -rf ${WORKSPACE}
	mkdir -p ${WORKSPACE}
	cp ${SRCLIST} ${WORKSPACE}/srclist
	
	dispatch "$$" "${WORKSPACE}/srclist"
	echo Done!
	exit 0
}

main $1 $2 $3 $4
