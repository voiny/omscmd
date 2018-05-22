#!/usr/bin/env python
#Compare object list with OBS

from com.obs.client.obs_client import ObsClient
import pdb
import sys
import os
import glob
from optparse import OptionParser
from itertools import islice

import multiprocessing
from multiprocessing import Pool
import time
import datetime

APP_PREFIX = "direct_compare"
THREAD_NUM = 1
END_FLAG = APP_PREFIX + "END_FLAG" + str(datetime.datetime.now())
WORKSPACE = "/data/tmp/direct_compare"
SOURCE_FILE = None
OUTPUT_FILE = None
BUCKET_NAME = "perftest2"
ENDPOINT = "obs.myhwclouds.com"
ACCESS_KEY = ""
SECRET_KEY = ""
PARSER = OptionParser()
PARSER.add_option("--ak", "--access_key",action="store", dest="access_key",help="Access key.")
PARSER.add_option("--sk", "--secret_key",action="store", dest="secret_key",help="Secret key.")
PARSER.add_option("-e", "--endpoint",action="store", dest="endpoint",help="Enpoint, https://xxx.xxx.xxx, e.g.")
PARSER.add_option("-b", "--bucket_name",action="store", dest="bucket_name",help="Bucket name.")
PARSER.add_option("-s", "--source_file",action="store", dest="source_file",help="Source file of full list of objects.")
PARSER.add_option("-o", "--output_file",action="store", dest="output_file",help="Output file.")
PARSER.add_option("-t", "--thread_num",action="store", type="int", dest="thread_num",help="Number of thread(s).")

PARSER.add_option("-w","--workspace_path",action="store",dest="workspace_path",help="Path of workspace, " + WORKSPACE + " by default.")
(options, args) = PARSER.parse_args()

class MigrationObject:
	def __init__(self):
		self.time = 0
		self.key = ''
		self.size = 0
		self.line = None

def datetime_string2timestamp_s(datetime_string, datetime_format):
	time_array = time.strptime(datetime_string, datetime_format)
	timestamp = time.mktime(time_array)
	return int(timestamp)

def datetime_string2timestamp_ms(datetime_string, datetime_format):
	return datetime_string2timestamp_s(datetime_string, datetime_format) * 1000

if options.thread_num:
	THREAD_NUM = options.thread_num

if options.workspace_path:
	WORKSPACE = options.workspace_path

if options.source_file:
	SOURCE_FILE = options.source_file

if options.output_file:
	OUTPUT_FILE = options.output_file

if options.access_key:
	ACCESS_KEY = options.access_key

if options.secret_key:
	SECRET_KEY = options.secret_key

if options.endpoint:
	ENDPOINT = options.endpoint

if options.bucket_name:
	BUCKET_NAME = options.bucket_name

def init():
	if os.path.exists(WORKSPACE):
		files = glob.glob(WORKSPACE + "/*")
		for one_file in files:
			os.remove(one_file)
	else:
		os.makedirs(WORKSPACE)

def timestamp2datetime_string_s(timestamp):
	time_local = time.localtime(timestamp)
	result = time.strftime("%Y-%m-%d %H:%M:%S", time_local)
	return result

def timestamp2datetime_string_ms(timestamp):
	timestamp = timestamp / 1000
	return timestamp2datetime_string_s(timestamp)

def generate_line(time, key, size):
	return str(time) + " " + key + " " + str(size)

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

def get_parts_from_line(line):
	parts = line.split()
	t = parts[0]
	length = len(parts)
	key = ""
	for i in range(1, length - 1):
		key += parts[i]
	size = parts[length - 1]
	return t, key, size

def parse_object(line):
	time, key, size = get_parts_from_line(line)
	obj = MigrationObject()
	obj.time = int(time)
	obj.key = key
	obj.size = int(size)
	obj.line = line
	return obj

def get_line_of_file(source_file):
	c = 0
	with open(file_name) as file:
		for line in file:
			c += 1
	return c

def generate_dictionaries(source_file, thread_num):
	c = 0
	dictionaries = {}
	for i in range(thread_num):
		dictionaries[i] = []
	with open(source_file) as one_file:
		split_num = 0
		for line in one_file:
			if c % 10000 == 0:
				sys.stdout.write("Processed lines: " + str(c))
				sys.stdout.write("\r")
				sys.stdout.flush()
			split_num = c % thread_num
			migration_object = parse_object(line)
			dictionaries[split_num].append(migration_object)
			c += 1
	sys.stdout.write("Procesed lines: " + str(c))
	sys.stdout.write("\r")
	sys.stdout.flush()
	print ("\n")
	return dictionaries

def is_time_a_after_b(time_a, time_b):
	return time_a > time_b

def read_object_info(obsClient, key):
	resp = obsClient.getObjectMetadata(BUCKET_NAME, key)
	obj = MigrationObject()
	
	try:
		if resp != None:
			# size
			size = int(resp.header[0][1])
			# datetime
			resp.header[2][1]
			t = datetime.datetime.strptime(resp.header[2][1], "%a, %d %b %Y %H:%M:%S GMT")	
			obj.key = key
			obj.time = int(time.mktime(t.timetuple())) * 1000
			obj.size = size
			return obj
	except:
		return None

def format_object(obj):
	last_modified = str(obj.last_modified)
	return last_modified  + "000 " + obj.key + " " + str(obj.size)

def format_migration_object(obj):
	last_modified = str(obj.time)
	return last_modified  + obj.key + " " + str(obj.size)

def is_key_a_after_or_equal_b(key_a, key_b):
	result = cmp(key_a, key_b)
	if result == 1 or result ==0:
		return True
	else:
		return False

def worker(worker_name, dictionary):
	obsClient = ObsClient(access_key_id=ACCESS_KEY, secret_access_key=SECRET_KEY, server=ENDPOINT, long_conn_mode=True)
	print ("Worker: " + worker_name + " started.")
	with open(WORKSPACE + "/" + worker_name, "a") as output_file:
		for obj in dictionary:
			print("Comparing " + obj.key + " ...\n")
			ret_obj = read_object_info(obsClient, obj.key)
			if ret_obj == None:
				# Error
				print("Failed find destination object: " + obj.key + "\n")
				output_file.write(obj.line)
			else:
				if is_time_a_after_b(obj.time, ret_obj.time) == True or obj.size != ret_obj.size:
					output_file.write(obj.line)
	obsClient.close()	
	print ("Worker: " + worker_name + " stopped.")

def merge_files(): 
	try:
		output_file = open(OUTPUT_FILE, "w")
		dictionary = {}
		for i in range(THREAD_NUM):
			# number of thread stars from 0
			subfile = WORKSPACE + "/" + APP_PREFIX + str(i)
			print ("Processing file " + subfile + "...\n")
			with open(subfile, "r") as one_subfile:
				for line in one_subfile:
					time, key, size = get_parts_from_line(line)
					dictionary[key] = (time, size)
					#output_file.write(line)
		for (key, value) in dictionary.items():
			output_file.write(generate_line(value[0], key, value[1]) + "\n")
	finally:
		if output_file:
			output_file.close()

def main():
	if not SOURCE_FILE or not OUTPUT_FILE or not BUCKET_NAME or not ENDPOINT or not ACCESS_KEY or not SECRET_KEY:
		PARSER.print_help()
		sys.exit()	
	time_start = datetime.datetime.now()
	print ("Start time: " + time_start.strftime("%Y-%m-%d %H:%M:%S") + "\n")
	print ("thread_num: " + str(THREAD_NUM) + ", workspace: " + WORKSPACE + "\n")
	init()
	with multiprocessing.Manager() as manager:
		pool = Pool(THREAD_NUM)
		print ("Generating dictionaries...\n")
		dictionaries = generate_dictionaries(SOURCE_FILE, THREAD_NUM)
		print ("Genarating dictionaries finished at: " + datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S") + "\n")
	#	worker(APP_PREFIX, dictionaries[0])
		for i in range(THREAD_NUM):
			pool.apply_async(worker, args=(APP_PREFIX + str(i), dictionaries[i]))
		pool.close()
		pool.join()
	print ("All thread processing finished at: " + datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S") + "\n")
	print ("Merging files...\n")
	merge_files()
	time_end = datetime.datetime.now()
	print ("Merging finished at: " + datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S") + "\n")
	print ("Time cost: " + str(time_end - time_start) + "ms\n")
	print ("Done!\n")

if __name__ == '__main__':
	#pdb.set_trace()
	main()
