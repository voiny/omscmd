#!/bin/bash

WORK_PATH="/tmp/tmp-"`date +"%F-%s-%N"` 
INSTALL_GIT="TRUE"
INSTALL_PIP="TRUE"
INSTALL_OSSSDK="TRUE"
INSTALL_OBSSDK="TRUE"

mkdir -p $WORK_PATH

if [[ "$INSTALL_GIT" == "TRUE" ]]; then
	echo Installing git
	yum install -y git
fi

if [[ "$INSTALL_PIP" == "TRUE" ]]; then
	echo Installing pip
	cd $WORK_PATH
	rm -rf $WORK_PATH/get-pip.py
	wget -O $WORK_PATH/get-pip.py https://bootstrap.pypa.io/get-pip.py
	python get-pip.py
fi

if [[ "$INSTALL_OSSSDK" == "TRUE" ]]; then
	echo Installing oss sdk
	pip install oss2
fi

if [[ "$INSTALL_OBSSDK" == "TRUE" ]]; then
	echo Installing obs sdk
	rm -rf $WORK_PATH/obssdk/
	mkdir -p $WORK_PATH/obssdk
	cd $WORK_PATH/obssdk
	wget -O $WORK_PATH/obssdk/obssdk.zip http://static.huaweicloud.com/upload/files/sdk/python.zip
	unzip obssdk.zip
	unzip eSDK*.zip
	cd $WORK_PATH/obssdk/src
	python setup.py install
fi

cd
rm -rf $WORK_PATH
