#!/bin/bash

source ./env.sh

rm -rf ${WORKSPACE}/list
${SRCTOOL} ls "${SRCPATH}" | tee ${WORKSPACE}/list

sed 's/.*PRE //' -i ${WORKSPACE}/list
sed 's/[0-9]\{4\}-[0-9]\{2\}-[0-9]\{2\} [0-9]\{2\}:[0-9]\{2\}:[0-9]\{2\}[ ]\+[0-9]\+ //' -i ${WORKSPACE}/list
