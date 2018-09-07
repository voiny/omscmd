#!/bin/bash

SRCLIST=""
THREADNUM=4
DSTREGION="cn-north-1"
DSTBUCKET=''
WORKSPACE="/data/tmp/stream_compare"
MAXTRY=1

function download()
{
	thread_name=$1
	line=$2
	download_file_full_path=${WORKSPACE}/${thread_name}_download
	rm -rf ${download_file_full_path}
	i=0
	while [[ ! -f "${download_file_full_path}" && ${i} -lt ${MAXTRY} ]]
	do
		aws --endpoint-url=http://obs.${DSTREGION}.myhwclouds.com --region=${DSTREGION} --profile=dst s3 cp "s3://${DSTBUCKET}/${line}" "${download_file_full_path}" > /dev/null
		let i+=1
	done
	if [ ${i} -gt ${MAXTRY} ]; then
		echo 0
	else
		echo 1
	fi
}

function exist_on_obs()
{
	thread_name=$1
	line=$2
	result=1
	i=0
	while [[ "${result}" != "0" && ${i} -lt ${MAXTRY} ]]
	do
		aws --endpoint-url=http://obs.${DSTREGION}.myhwclouds.com --region=${DSTREGION} --profile=dst s3 ls "s3://${DSTBUCKET}/${line}" > /dev/null
		result="$?"
		let i+=1
	done
	if [[ "${result}" == "0" ]]; then
		echo 1
	else
		echo 0
	fi
}

function verify_hash()
{
	thread_name=$1
	list=$2
	key=`echo $list | awk '{for (i=2;i<=NF-2;i++) printf("%s ", $i);}'|sed 's/ $//'`
	hash_in_list=`echo $list | awk '{printf("%s", $NF);}'`
	local_file_hash=""
	result=0
	exist_on_obs_result=`exist_on_obs "${thread_name}" "${key}"`
	if [[ "${exist_on_obs_result}" == "1" ]]; then
		download_result=`download "${thread_name}" "${key}"`
		if [[ "${download_result}" == "1" ]]; then
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
	echo ${thread_name}>&5
}

function dispatch()
{
	thread_name=$1
	list=$2
	mkfifo ${WORKSPACE}/fifo
	exec 5<>${WORKSPACE}/fifo
	rm -rf ${WORKSPACE}/fifo
	
	for ((i=1;i<=${THREADNUM};i++))
	do
		echo $i
	done >&5

	cat $list | while read line
	do
		read -u5 i
		{
			verify_hash "$i" "$line"
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
	
	WORKSPACE="/data/tmp/stream_compare/${DSTBUCKET}"
	rm -rf ${WORKSPACE}
	mkdir -p ${WORKSPACE}
	dispatch "$$" "${SRCLIST}"
	echo Done!
	exit 0
}

main $1 $2 $3 $4
