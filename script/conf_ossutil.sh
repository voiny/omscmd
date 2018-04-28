#!/bin/bash

source ./env.sh
export PATH=$PATH:/usr/bin

echo [Credentials] > /root/.ossutilconfig
echo language=EN >> /root/.ossutilconfig
echo endpoint=oss-${SRCREGION}.aliyuncs.com >> /root/.ossutilconfig
echo accessKeyID=${SRCAK} >> /root/.ossutilconfig
echo accessKeySecret=${SRCSK} >> /root/.ossutilconfig

ossutil ls
