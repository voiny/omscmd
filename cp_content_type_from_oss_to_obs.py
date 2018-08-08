#!/usr/bin/env python
#coding:utf-8
import sys

reload(sys)
sys.setdefaultencoding('utf-8')

import oss2
import pdb
import sys
import os
import glob
from optparse import OptionParser
from itertools import islice

from com.obs.client.obs_client import ObsClient
from com.obs.client.obs_client import PutObjectHeader
from com.obs.client.obs_client import CopyObjectHeader

import multiprocessing
from multiprocessing import Pool
import time
import datetime

LISTING_FINISH = False
APP_PREFIX = "cp_content_type"
THREAD_NUM = 1
END_FLAG = APP_PREFIX + "END_FLAG" + str(datetime.datetime.now())
WORKSPACE = "/tmp/cp_content_type_from_oss_to_obs"
OSS_BUCKET_NAME = ""
OBS_BUCKET_NAME = ""
OSS_ENDPOINT = "https://oss-cn-beijing.aliyuncs.com"
OBS_ENDPOINT = "obs.myhwclouds.com"
OSS_ACCESS_KEY = ""
OSS_SECRET_KEY = ""
OBS_ACCESS_KEY = ""
OBS_SECRET_KEY = ""
OBS_PATH = ""
PARSER = OptionParser()
PARSER.add_option("--ossak", "--oss_access_key",action="store", dest="oss_access_key",help="OSS Access key.")
PARSER.add_option("--osssk", "--oss_secret_key",action="store", dest="oss_secret_key",help="OSS Secret key.")
PARSER.add_option("--obsak", "--obs_access_key",action="store", dest="obs_access_key",help="OBS Access key.")
PARSER.add_option("--obssk", "--obs_secret_key",action="store", dest="obs_secret_key",help="OBS Secret key.")
PARSER.add_option("--osse", "--oss_endpoint",action="store", dest="oss_endpoint",help="OSS enpoint, oss-cn-beijing.aliyuncs.com, e.g.")
PARSER.add_option("--obse", "--obs_endpoint",action="store", dest="obs_endpoint",help="OBS enpoint, obs.myhwclouds.com, e.g.")
PARSER.add_option("--ossb", "--oss_bucket_name",action="store", dest="oss_bucket_name",help="OSS bucket name.")
PARSER.add_option("--obsb", "--obs_bucket_name",action="store", dest="obs_bucket_name",help="OBS bucket name.")
PARSER.add_option("--obsp", "--obs_path",action="store", dest="obs_path",help="OBS destination path. For root, input \"/\" or ignore this parameter, for other path, input \"/other_path_name/\"")
PARSER.add_option("-t", "--thread_num",action="store", type="int", dest="thread_num",help="Number of thread(s).")
PARSER.add_option("-w","--workspace_path",action="store",dest="workspace_path",help="Path of workspace, " + WORKSPACE + " by default.")
(options, args) = PARSER.parse_args()

class MigrationObject:
        def __init__(self):
                self.key=''
		self.content_type=''

if options.thread_num:
	THREAD_NUM = options.thread_num

if options.workspace_path:
	WORKSPACE = options.workspace_path

if options.oss_access_key:
	OSS_ACCESS_KEY = options.oss_access_key

if options.oss_secret_key:
	OSS_SECRET_KEY = options.oss_secret_key

if options.obs_access_key:
	OBS_ACCESS_KEY = options.obs_access_key	

if options.obs_secret_key:
	OBS_SECRET_KEY = options.obs_secret_key

if options.oss_endpoint:
	OSS_ENDPOINT = "https://" + options.oss_endpoint

if options.obs_endpoint:
	OBS_ENDPOINT = options.obs_endpoint

if options.oss_bucket_name:
	OSS_BUCKET_NAME = options.oss_bucket_name

if options.obs_bucket_name:
	OBS_BUCKET_NAME = options.obs_bucket_name

if options.obs_path:
	OBS_PATH = options.obs_path[1:]

def init():
	if os.path.exists(WORKSPACE):
		files = glob.glob(WORKSPACE + "/*")
		for one_file in files:
			os.remove(one_file)
	else:
		os.makedirs(WORKSPACE)

def write_queue(queue, lock, value):
	lock.acquire()
	queue.put(value)
	lock.release()

def read_queue(queue, lock):
	lock.acquire()
	result = None
	try:
		result = queue.get(False)
	except:
		result = None
	lock.release()
	return result

def worker(worker_name, queue, lock):
	print ("Worker: " + worker_name + " started.")
	global LISTING_FINISH
	headers = CopyObjectHeader()
	headers.directive = "REPLACE"
	oss_auth = oss2.Auth(OSS_ACCESS_KEY, OSS_SECRET_KEY)
	oss_bucket = oss2.Bucket(oss_auth,OSS_ENDPOINT, OSS_BUCKET_NAME)
	obs_client = ObsClient(access_key_id=OBS_ACCESS_KEY, secret_access_key=OBS_SECRET_KEY, server=OBS_ENDPOINT, long_conn_mode=True)
	while True:
		mo = read_queue(queue, lock)
		if mo != None:
			meta = oss_bucket.head_object(mo.key)                                                                                                                                                                                                                                        	
	        	if meta == None or meta.status != 200 or meta.content_type == None:
	        		print(worker_name + " - Meta is None for key: " + mo.key)
	        		continue
	        	mo.content_type = meta.content_type
	        	headers.contentType = mo.content_type
			resp = obs_client.getObjectMetadata(OBS_BUCKET_NAME, OBS_PATH + mo.key)
			if resp.status >= 300:
	        		print(worker_name + " - Error: oss://" + OSS_BUCKET_NAME + "/" + mo.key + " -> " + "obs://" + OBS_BUCKET_NAME + "/" + OBS_PATH + mo.key + " Content-Type: " + mo.content_type + ", ErrorCode: " + str(resp.status) + ", ErrorMessage: " + resp.reason)
				continue
			from_content_type = resp.body.contentType
			resp = obs_client.copyObject(OBS_BUCKET_NAME, OBS_PATH + mo.key, OBS_BUCKET_NAME, OBS_PATH + mo.key, headers=headers)
	        	if resp.status < 300:
	        		print(worker_name + " - Done: oss://" + OSS_BUCKET_NAME + "/" + mo.key + " -> " + "obs://" + OBS_BUCKET_NAME + "/" + OBS_PATH + mo.key + " Content-Type: from " + from_content_type + " to " + mo.content_type)
	        	else:    
	        		print(worker_name + " - Error: oss://" + OSS_BUCKET_NAME + "/" + mo.key + " -> " + "obs://" + OBS_BUCKET_NAME + "/" + OBS_PATH + mo.key + " Content-Type: from " + from_content_type + " to " + mo.content_type + ", ErrorCode: " + str(resp.errorCode) + ", ErrorMessage: " + resp.errorMessage)
		else:
			if LISTING_FINISH == True:
				print("Thread: " + worker_name + " exited.\n")
				obs_client.close()
				return
			else:
				time.sleep(1)

def list_src(queue, lock, bucket_name, full_endpoint, ak, sk):
	global LISTING_FINISH
	auth = oss2.Auth(ak, sk)
	bucket = oss2.Bucket(auth, full_endpoint, bucket_name)
	i = 0
	for obj in islice(oss2.ObjectIterator(bucket), None):
		if (i % 10000 == 0):
			sys.stdout.write("Loading: " + str(i) + " objects...")
			sys.stdout.write("\r")
			sys.stdout.flush()
		i += 1
		mo = MigrationObject()
		mo.key = obj.key
		write_queue(queue, lock, mo)
	sys.stdout.write("Loading: " + str(i) + " objects...")
	sys.stdout.write("\r")
	sys.stdout.flush()
	print("\n")
	LISTING_FINISH = True

def main():
	if not OSS_BUCKET_NAME or not OBS_BUCKET_NAME or not OSS_ENDPOINT or not OSS_ACCESS_KEY or not OSS_SECRET_KEY or not OBS_ACCESS_KEY or not OBS_SECRET_KEY:
		print("Example: [this_command.py] --ossak [OSS_AK] --osssk [OSS_SK] --osse oss-cn-beijing.aliyuncs.com --ossb [OSS_BUCKET_NAME] --obsak [OBS_AK] --obssk [OBS_SK] --obsb [OBS_BUCKET_NAME] --obsp /path_name/")
		PARSER.print_help()
		sys.exit()	
	time_start = datetime.datetime.now()
	print ("Start time: " + time_start.strftime("%Y-%m-%d %H:%M:%S") + "\n")
	print ("Thread count: " + str(THREAD_NUM) + ", workspace: " + WORKSPACE + "\n")
	init()
	with multiprocessing.Manager() as manager:
		lock = manager.Lock()
		queue = manager.Queue()
		pool = Pool(THREAD_NUM)
		print ("Listing object...")
		list_src(queue, lock, OSS_BUCKET_NAME, OSS_ENDPOINT, OSS_ACCESS_KEY, OSS_SECRET_KEY)
		print ("Finished listing object at: " + datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S") + "\n")
		print ("Starting threads...\n")
		#worker(APP_PREFIX + "0", queue, lock)
		for i in range(THREAD_NUM):
			pool.apply_async(worker, args=(APP_PREFIX + str(i), queue, lock))
		pool.close()
		pool.join()
	print ("All thread processing finished at: " + datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S") + "\n")
	time_end = datetime.datetime.now()
	print ("Time cost: " + str(time_end - time_start) + "ms\n")
	print ("Done!\n")

if __name__ == '__main__':
	#pdb.set_trace()
	main()
