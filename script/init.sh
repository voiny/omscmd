#!/bin/bash

source ./env.sh

yum -y install cloud-init
yum -y install epel-release
yum -y install jq

cd ${WORKSPACE}
rm -rf obssdk.zip
wget -O ${WORKSPACE}/obssdk.zip http://static.huaweicloud.com/upload/files/sdk/python.zip
unzip obssdk.zip
unzip eSDK*.zip
cd ${WORKSPACE}/src
python setup.py install

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
	pip install qiniu
	
	rm -rf /usr/bin/qrsctl
	rm -rf /tmp/qrsctl
	wget -O /tmp/qrsctl http://devtools.qiniu.com/linux/amd64/qrsctl
	cp /tmp/qrsctl /usr/bin/qrsctl
	chmod 550 /usr/bin/qrsctl
	qrsctl login ${SRCAK} ${SRCSK}
	
	rm -rf /usr/bin/qshell
	rm -rf /tmp/qshell.zip
	wget -O /tmp/qshell.zip http://devtools.qiniu.com/qshell-v2.1.8.zip?ref=developer.qiniu.com
	unzip /tmp/qshell.zip -d /tmp/
	cp /tmp/qshell-linux-x64 /usr/bin/qshell
	chmod 550 /usr/bin/qshell
	./conf_qshell.sh
elif [ "$SRCTOOL" == "bcdcmd" ]; then
	wget -O /tmp/bce-python-sdk.zip https://sdk.bce.baidu.com/console-sdk/bce-python-sdk-0.8.19.zip
	cd /tmp
	unzip bce-python-sdk.zip
	cd /tmp/bce-python-sdk-0.8.19
	python setup.py install
	
	wget -O /tmp/bcecmd.zip https://sdk.bce.baidu.com/console-sdk/linux-bcecmd-0.2.2.zip
	cd /tmp
	unzip bcecmd.zip
	/usr/bin/cp -f bcecmd /usr/bin/
	cd ${ORIGINAL_DIRECTORY}
	./conf_bcecmd.sh
else
	cd ${WORKSPACE}
	wget https://bootstrap.pypa.io/get-pip.py
	python get-pip.py
	pip install awscli
	cd ${ORIGINAL_DIRECTORY}
	./conf_awscli.sh
fi
