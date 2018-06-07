#!/usr/bin/env python
#coding:utf-8
import sys

reload(sys)
sys.setdefaultencoding('utf-8')

from com.obs.client.obs_client import ObsClient

obsClient = ObsClient(
    access_key_id='',    
    secret_access_key='',    
    server='obs.myhwclouds.com'
)

index = 1
nextPartNumberMarker = None
# 每页100个段
maxParts = 1000
while True: 
    # 列举已上传的段，其中uploadId来自于initiateMultipartUpload
    resp = obsClient.listParts('bucketname', 'key', uploadId='uploadId', partNumberMarker=nextPartNumberMarker, maxParts=100)
    if resp.status < 300:
        print('requestId:', resp.requestId)
        for part in resp.body.parts:        
            print('part [' + str(index) + ']')
            # 分段号，上传时候指定      
            print('partNumber:', part.partNumber)        
            # 段的最后上传时间
            print('lastModified:', part.lastModified)
            # 分段的ETag值        
            print('etag:', part.etag)    
            # 段数据大小    
            print('size:', part.size)        
            index += 1
        if not resp.body.isTruncated:
            break
        nextPartNumberMarker = resp.body.nextPartNumberMarker
    else:    
        print('errorCode:', resp.errorCode)
        print('errorMessage:', resp.errorMessage)
        break 
