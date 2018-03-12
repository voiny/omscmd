#!/bin/bash

source ./env.sh

rm -rf ${WORKSPACE}/list
${SRCTOOL} ${SRCTOOL_ARG_LS} ${SRCTOOL_ARG_NONRECURSIVE} "${SRCPATH}" | tee ${WORKSPACE}/list

if [ "${SRCTOOL}" == "aws" ]; then
	sed 's/.*PRE //' -i ${WORKSPACE}/list
	sed 's/[0-9]\{4\}-[0-9]\{2\}-[0-9]\{2\} [0-9]\{2\}:[0-9]\{2\}:[0-9]\{2\}[ ]\+[0-9]\+ //' -i ${WORKSPACE}/list
elif [ "${SRCTOOL}" == "ossutil" ]; then
	sed '$d' -i ${WORKSPACE}/list 
	sed '$d' -i ${WORKSPACE}/list 
	sed "s#${SRCPATH}##" -i ${WORKSPACE}/list 
	sed '/^\s*$/d' -i ${WORKSPACE}/list 
fi
