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

from com.obs.models.list_multipart_uploads_request import ListMultipartUploadsRequest
multipart = ListMultipartUploadsRequest()

multipart.max_uploads = 1000

while True:
    resp = obsClient.listMultipartUploads('bucketname', multipart=multipart)
    if resp.status < 300:
        print('requestId:', resp.requestId)
        index = 1
        for upload in resp.body.upload:
            print('upload [' + str(index) + ']')
            print('key:', upload.key)
            print('uploadId:', upload.uploadId)
            print('initiated:', upload.initiated)
            index += 1
            
        if not resp.body.isTruncated:
            break
        multipart.key_marker = resp.body.nextKeyMarker
        multipart.upload_id_marker = resp.body.nextUploadIdMarker
    else:
        print('status:', resp.status)
        break 
