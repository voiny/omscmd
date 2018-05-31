#!/bin/bash

source ./env.sh

yum -y install cloud-init
if [ "$SRCTOOL" == "s3cmd" ]; then
	cd ${WORKSPACE}
	wget https://bootstrap.pypa.io/get-pip.py
	python get-pip.py
	pip install s3cmd
	cd ${ORIGINAL_DIRECTORY}
	./conf_s3cmd.sh
elif [ "$SRCTOOL" == "ossutil" ]; then
	rm -rf /usr/bin/ossutil
	wget -O /usr/bin/ossutil http://docs-aliyun.cn-hangzhou.oss.aliyun-inc.com/assets/attach/50452/cn_zh/1516454058701/ossutil64?spm=a2c4g.11186623.2.6.YHvNcQ
	chmod 550 /usr/bin/ossutil
	cd ${ORIGINAL_DIRECTORY}
	./conf_ossutil.sh
elif [ "$SRCTOOL" == "qshell" ]; then
	rm -rf /usr/bin/qshell
	wget -O /tmp/qshell.zip http://devtools.qiniu.com/qshell-v2.1.8.zip?ref=developer.qiniu.com
	unzip /tmp/qshell.zip -d /tmp/
	cp /tmp/qshell-linux-x64 /usr/bin/qshell
	chmod 550 /usr/bin/qshell
	./conf_qshell.sh
else
	cd ${WORKSPACE}
	wget https://bootstrap.pypa.io/get-pip.py
	python get-pip.py
	pip install awscli
	cd ${ORIGINAL_DIRECTORY}
	./conf_awscli.sh
fi
