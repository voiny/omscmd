#!/bin/bash

source ./conf.sh

function exec_sql() {
	echo "$1"
	mysql -uroot -p${DB_PWD} -e"$1"
}

function stop_all() {
	SQL="use S3Migration;select id,description from tb_task;"
	exec_sql "${SQL}" > ${WORKSPACE}/tmp_stopall
	sed '1d' -i ${WORKSPACE}
	cat ${WORKSPACE}/tmp_stopall | awk '{print $1}' > ${WORKSPACE}/tmp_stopall2
	rm -rf tmp_stopall
	IDS=`cat ${WORKSPACE}/tmp_stopall2`
	COUNTER=0
	for ID in ${IDS}
	do
		let COUNTER+=1
		echo ${COUNTER}
		curl -H "Content-Type:application/json" --insecure -X POST --data "{\"operation\":\"stop\"}" https://127.0.0.1:8443/maas/ret/v1/0000000000/obectstorage/changeState/${ID}
	done
	rm -rf ${WORKSPACE}/tmp_stopall2
}

function get_all_task_status() {
	SQL="use S3Migration;select id,description,status from tb_task;"
	if [ "$1" != "" ];then
		SQL="use S3Migration;select id,description,status from tb_task where status = $1;"
	fi
	exec_sql "${SQL}"
	echo
	echo Status Explaination:
	echo initializing - 0, waiting - 1, running -2, pause - 3, fail - 4, success - 5, retying - 6
}

function get_task_status() {
	SQL="use S3Migration;select id,taskName,description,status from tb_task where id=$1;"
	exec_sql "${SQL}"
	echo
	echo Status Explaination:
	echo initializing - 0, waiting - 1, running -2, pause - 3, fail - 4, success - 5, retying - 6
}

function stop_task() {
	curl -H "Content-Type:application/json" --insecure -X POST --data "{\"operation\":\"stop\"}" https://127.0.0.1:8443/maas/ret/v1/0000000000/obectstorage/changeState/$1
}

function resume_task() {
	curl -H "Content-Type:application/json" --insecure -X POST --data "{\"operation\":\"start\",\"source_ak\":\"${SRCAK}\",\"source_sk\":\"${SRCSK}\",\"target_ak\":\"${DSTAK}\",\"target_sk\":\"${DSTSK}\"}" https://127.0.0.1:8443/maas/ret/v1/0000000000/obectstorage/changeState/$1
}

function help() {
	echo "Task Management:"
	echo "	Parameters:"
	echo "		get_all_task_status"
	echo "		get_task_status taskId"
	echo "		stop_task taskId"
	echo "		resume_task taskId"
}

case $1 in
	'get_all_task_status')
		get_all_task_status
		;;
	'stop_all')
		stop_all
		;;
	'get_task_status')
		get_task_status $2
		;;
	'stop_task')
		stop_task $2
		;;
	'resume_task')
		resume_task $2
		;;
	*)
		help
		;;
esac
