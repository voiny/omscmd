#!/bin/bash

WORKSPACE='/opt/oms'
CONFIG_FILE="$WORKSPACE/create_task.properties"
RECORD_FILE="$WORKSPACE/result.properties"
getValueFromVars()
{
    local key="$1"
    local value=$(grep "^$key" $CONFIG_FILE | sed "s#^$key=##")
    echo "${value}" | xargs | tr -d '\r'
}

function query_auth_token()
{
	tenant_name=$(getValueFromVars tenant_name)
    tenant_password=$(getValueFromVars tenant_password)
    domain_name=$(getValueFromVars domain_name)
    project_id=$(getValueFromVars project_id)
	#You need to modify the name and password in user to create a task user, name in domain is the attribution domain name, project is the region ID of the current Huawei Cloud
	replaced_body=`echo "{ 'auth': { 'identity': { 'methods': ['password'], 'password': { 'user': { 'name': '{{tenant_name}}', 'password': '{{tenant_password}}', 'domain': { 'name': '{{domain_name}}' } } } }, 'scope': { 'project': { 'id': '{{project_id}}' } } } }" | sed "s#{{tenant_name}}#$tenant_name#" | sed "s#{{tenant_password}}#$tenant_password#" | sed "s#{{domain_name}}#$domain_name#" | sed "s#{{project_id}}#$project_id#"`
    token_info=$(curl -i -k -H 'Connection: keep-alive' -H 'X-Language:en-us' -H 'Content-Type: application/json' -d "$replaced_body" -X POST 'https://iam.myhuaweicloud.com:443/v3/auth/tokens')
    token_auth_info=`echo "$token_info" | tr -d "\r" | sed -n "/X-Subject-Token/p" | awk -F "[: ]" '{print $3}'`
    
    echo $token_auth_info
}

function create_task()
{
	user_token=`query_auth_token`
	# project_id please keep in line with token
	project_id=$(getValueFromVars project_id)
	#source region ID.
	src_region=$(getValueFromVars src_region)
	#source ak
	src_ak=$(getValueFromVars src_ak)
	#source sk
	src_sk=$(getValueFromVars src_sk)
	#source bucket
	src_bucket=$(getValueFromVars src_bucket)
	#source cloud type,[亚马逊->AWS, 阿里云->Aliyun, 腾讯云->Tencent, 青云->QingCloud, 七牛云->Qiniu, 百度云->Baidu, 金山云->KingsoftCloud]
	src_cloud_type=$(getValueFromVars src_cloud_type)
	#源端路径和迁移对象,比如迁移test桶下test目录下x.txt和y.txt,则keys为'["test/x.txt","test/y.txt"]'
	src_path=$(getValueFromVars src_path)
	src_keys=$(getValueFromVars src_keys)

	#destination region ID.
	dst_region=$(getValueFromVars dst_region)
	#destination ak
	dst_ak=$(getValueFromVars dst_ak)
	#destination sk
	dst_sk=$(getValueFromVars dst_sk)
	#destination bucket
	dst_bucket=$(getValueFromVars dst_bucket)
	#destination cloud type, Only HEC is supported.
	dst_cloud_type=$(getValueFromVars dst_cloud_type)

	# Number of Migrated Threads
	thread_num=$(getValueFromVars thread_num)
	# Indicates whether to enable KMS encryption.
	enableKMS=$(getValueFromVars enableKMS)
	# indicates whether to enable the failure object record.
	enable_failed_object_recording=$(getValueFromVars enable_failed_object_recording)
	# Task Description
	description=$(getValueFromVars description)
	# Indicates the object after the migration. If full migration is required, you do not need to set this parameter.
	enable_time_filter_object=$(getValueFromVars enable_time_filter_object)
	echo $enable_time_filter_object
	migration_since=''
	if [ $enable_time_filter_object == true ];then
		echo 1
		migration_time=$(getValueFromVars migration_since)
		migration_since=`date -d "$migration_time" +%s`
	else
		migration_since=''
	fi
echo $migration_since
	request_body="{'src_node':{'region':'$src_region','ak':'$src_ak','sk':'$src_sk','bucket':'$src_bucket','cloud_type':'$src_cloud_type','object_key':{'path':'$src_path','keys':$src_keys}},'thread_num':$thread_num,'enableKMS':$enableKMS,'description':'$description','dst_node':{'region':'$dst_region','ak':'$dst_ak','sk':'$dst_sk','object_key':'','bucket':'$dst_bucket','cloud_type':'$dst_cloud_type'},'enable_failed_object_recording':$enable_failed_object_recording,'task_type':'prefix','migrate_since':'$migration_since'}"
	
result=`curl -i -k -H 'Connection: keep-alive' -H 'X-Language:en-us' -H 'Content-Type: application/json' -H "X-Auth-Token:$user_token" -d "$request_body" -X POST "https://oms.myhuaweicloud.com:443/v1/$project_id/objectstorage/task"`

	if [ ! -f $RECORD_FILE ]; then
		touch $RECORD_FILE
	fi
	record_count=`cat $RECORD_FILE | wc -l`
	max_record=$(getValueFromVars max_record)
	if [ $record_count -ge $max_record ]; then
		sed -i '1d' $RECORD_FILE
	fi

	now_time=`date "+%Y-%m-%d %H:%M:%s"`
	echo result_$now_time=$result >> $RECORD_FILE
	
	is_success=`echo $result | grep 'task_name'`
	if [[ $is_success =~ "task_name" ]]; then
		now_date=`date +"%Y-%m-%d %H:%M:%S"`
		sed -i "s/^migration_since=.*/migration_since=$now_date/g" $CONFIG_FILE
		
	fi
	
}

create_task



