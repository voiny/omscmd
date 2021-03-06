#!/bin/bash

source ./conf.sh

function exec_sql() {
	echo "$1"
	mysql -uroot -p${DB_PWD} -e"$1"
}

function clean() {
	SQL="use S3Migration;delete from tb_task;delete from tb_node;"
	exec_sql "${SQL}"
}

function stop_all() {
	SQL="use S3Migration;update tb_task set status=3 where status=1;"
	exec_sql "${SQL}"
	SQL="use S3Migration;select id,description from tb_task where status=2 or status=6;"
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
		RESULT=`curl "https://127.0.0.1:8099/v1/0000000000/objectstorage/task/${ID}" --insecure -X PUT --data '{"operation":"stop"}' -H "Content-Type:application/json"`
		echo ${RESULT}
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
	echo initializing - 0, waiting - 1, running - 2, pause - 3, fail - 4, success - 5, retrying - 6
}

function get_task_status() {
	SQL="use S3Migration;select id,taskName,description,status from tb_task where id=$1;"
	exec_sql "${SQL}"
	echo
	echo Status Explaination:
	echo initializing - 0, waiting - 1, running - 2, pause - 3, fail - 4, success - 5, retrying - 6
}

function stop_task() {
 	RESULT=`curl "https://127.0.0.1:8099/v1/0000000000/objectstorage/task/$1" --insecure -X PUT --data '{"operation":"stop"}' -H "Content-Type:application/json"`
	echo ${RESULT}
	get_task_status $1
}

function restart_task() {
	DATA="{\"operation\":\"start\",\"source_ak\":\"${SRCAK}\",\"source_sk\":\"${SRCSK}\",\"target_ak\":\"${DSTAK}\",\"target_sk\":\"${DSTSK}\"}"
 	RESULT=`curl "https://127.0.0.1:8099/v1/0000000000/objectstorage/task/$1" --insecure -X PUT --data "${DATA}" -H "Content-Type:application/json"`
	echo ${RESULT}
	get_task_status $1
}

function restart_all() {
	if [ "$1" == "" ];then
		SQL="use S3Migration;select id,description from tb_task where status = 3 or status = 4;"
	else
		SQL="use S3Migration;select id,description from tb_task where status = $1;"
	fi
	
	exec_sql "${SQL}" > ${WORKSPACE}/tmp_restartall
	sed '1d' -i ${WORKSPACE}
	cat ${WORKSPACE}/tmp_restartall | awk '{print $1}' > ${WORKSPACE}/tmp_restartall2
	rm -rf tmp_restartall
	IDS=`cat ${WORKSPACE}/tmp_restartall2`
	COUNTER=0
	for ID in ${IDS}
	do
		let COUNTER+=1
		echo ${COUNTER}:
		DATA="{\"operation\":\"start\",\"source_ak\":\"${SRCAK}\",\"source_sk\":\"${SRCSK}\",\"target_ak\":\"${DSTAK}\",\"target_sk\":\"${DSTSK}\"}"
 		RESULT=`curl "https://127.0.0.1:8099/v1/0000000000/objectstorage/task/$ID" --insecure -X PUT --data "${DATA}" -H "Content-Type:application/json"`
		echo ${RESULT}
	done
	rm -rf ${WORKSPACE}/tmp_restartall2
}

function help() {
	echo "Task Management:"
	echo "	Parameters:"
	echo "		get_all_task_status"
	echo "		stop_all"
	echo "		get_task_status taskId"
	echo "		stop_task taskId"
	echo "		restart_task taskId"
	echo "		restart_all [status]"
	echo "		clean (clean tasks in database)"
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
	'restart_task')
		restart_task $2
		;;
	'restart_all')
		restart_all $2
		;;
	'clean')
		clean
		;;
	*)
		help
		;;
esac
