#!/bin/bash

if [ "$1" == "" ];then
	echo [command] cmc_output_path
	exit
fi

PARENT_PATH=$1
TENANT_NAME=''
TENANT_PASSWORD=''
DOMAIN_NAME=''
PROJECT_ID=''
DESCRIPTION_PREFIX=''
SRCAK=''
SRCSK=''
DSTAK=''
DSTSK=''

rm -rf /tmp/tmp_output

echo "curl -H 'Content-Type:application/json' --insecure -X POST --data '{\"auth\":{\"identity\":{\"methods\":[\"password\"],\"password\":{\"user\":{\"name\":\"${TENANT_NAME}\",\"password\":\"${TENANT_PASSWORD}\",\"domain\":{\"name\":\"${DOMAIN_NAME}\"}}}},\"scope\":{\"project\":{\"id\":\"${PROJECT_ID}\"}}}}' https://iam.cn-north-1.myhuaweicloud.com/v3/auth/tokens -D /tmp/response_head_tmp.txt>/dev/null">/tmp/tmp_run.sh
bash /tmp/tmp_run.sh
rm -rf /tmp/tmp_run.sh
TOKEN=`cat /tmp/response_head_tmp.txt | grep X-Subject-Token: | sed -n 's/X-Subject-Token: //p'`

PATHS=`ls ${PARENT_PATH}`

for path in ${PATHS[@]}
do
	FILES=`ls ${PARENT_PATH}/${path}`
	for file in ${FILES[@]}
	do
		LINES=`cat ${PARENT_PATH}/${path}/${file}`
		keys=''
		OLDIFS="$IFS"
		IFS=$'\n'
		for line in ${LINES[@]}
		do
			keys=${keys}\"${line}\",
		done
		IFS=$OLDIFS
		keys=`echo ${keys}|sed 's/,$//'|sed 's/\\\\/\\\\\\\\/g'`
		bucketname=${path}
		description=${DESCRIPTION_PREFIX}${file}
		domain=""
		#Get domain
		if [ "${domain}" == "" ];then
			for i in `qshell domains ${bucketname}`
			do
				if [[ "$i" =~ "hjfile.cn" ]];then
					domain=$i
					break
				fi
			done
		fi
		if [ "${domain}" == "" ];then
			for i in `qshell domains ${bucketname}`
			do
				if [[ "$i" =~ "clouddn.com" ]];then
					echo > /dev/null
				elif [[ "$i" =~ "qiniu" ]];then
					echo > /dev/null
				else
					domain=$i
				fi
			done
		fi
		if [ "${domain}" == "" ];then
			for i in `qshell domains ${bucketname}`
			do
				if [[ "$i" =~ "qiniu" ]];then
					domain=$1
				elif [[ "$i" =~ "clouddn.com" ]];then
					domain=$i
				else
					domain=$i
				fi
			done
		fi
		echo Processing file: ${PARENT_PATH}/${path}/${file}
		echo domain: $domain
		echo "curl -H 'Content-Type:application/json' -H 'X-Auth-Token:${TOKEN}' --insecure -X POST --data '{\"src_node\":{\"region\":\"z0\",\"ak\":\"${SRCAK}\",\"sk\":\"${SRCSK}\",\"bucket\":\"${bucketname}\",\"cloud_type\":\"Qiniu\",\"object_key\":{\"path\":\"/\",\"keys\":[${keys}]}},\"thread_num\":50,\"enableKMS\":false,\"description\":\"${description}\",\"dst_node\":{\"region\":\"cn-east-2\",\"ak\":\"${DSTAK}\",\"sk\":\"${DSTSK}\",\"object_key\":\"/\",\"bucket\":\"${bucketname}\",\"cloud_type\":\"HEC\"},\"source_cdn\":{\"protocol\":\"https\",\"domain\":\"${domain}\",\"authentication_type\":\"QINIU_PRIVATE_AUTHENTICATION\"},\"task_type\":\"object\",\"smnInfo\":{\"topicUrn\":\"urn:smn:cn-north-1:e9eb6fe5720b4037a5d2dafb3cfdc8a2:OCS-DFS-Migration\",\"triggerConditions\":[\"SUCCESS\"],\"language\":\"zh-cn\"}}' https://oms.myhuaweicloud.com/v1/${PROJECT_ID}/objectstorage/task" > /tmp/tmp_run.sh
		echo "curl -H 'Content-Type:application/json' -H 'X-Auth-Token:\${TOKEN}' --insecure -X POST --data '{\"src_node\":{\"region\":\"z0\",\"ak\":\"${SRCAK}\",\"sk\":\"${SRCSK}\",\"bucket\":\"${bucketname}\",\"cloud_type\":\"Qiniu\",\"object_key\":{\"path\":\"/\",\"keys\":[${keys}]}},\"thread_num\":50,\"enableKMS\":false,\"description\":\"${description}\",\"dst_node\":{\"region\":\"cn-east-2\",\"ak\":\"${DSTAK}\",\"sk\":\"${DSTSK}\",\"object_key\":\"/\",\"bucket\":\"${bucketname}\",\"cloud_type\":\"HEC\"},\"source_cdn\":{\"protocol\":\"https\",\"domain\":\"${domain}\",\"authentication_type\":\"QINIU_PRIVATE_AUTHENTICATION\"},\"task_type\":\"object\",\"smnInfo\":{\"topicUrn\":\"urn:smn:cn-north-1:e9eb6fe5720b4037a5d2dafb3cfdc8a2:OCS-DFS-Migration\",\"triggerConditions\":[\"SUCCESS\"],\"language\":\"zh-cn\"}}' https://oms.myhuaweicloud.com/v1/${PROJECT_ID}/objectstorage/task"
		bash /tmp/tmp_run.sh >> /tmp/tmp_output
		read input
		rm -rf /tmp/tmp_run.sh
	done
done
