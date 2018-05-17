#!/usr/bin/env python

import oss2
import pdb
import sys
import os
import glob
from optparse import OptionParser
from itertools import islice


import threading
import Queue
import time
import datetime

APP_PREFIX = "quick_compare"
THREAD_NUM = 1
#the number of keys that a section contains
SECTION_SIZE = 10000
WORKSPACE = "/data/tmp/quick_compare"
SOURCE_FILE = None
OUTPUT_FILE = None
BUCKET_NAME = "perftest1"
SEPARATE_TIME = None
ENDPOINT = "http://oss-cn-beijing.aliyuncs.com"
ACCESS_KEY = "LTAI4uUTSs8oJFNO"
SECRET_KEY = "6h9axkuayKvJGK7gTSdhE87Mwal41"
PARSER = OptionParser()
PARSER.add_option("--ak","--access_key",action="store", dest="access_key",help="Access key.")
PARSER.add_option("--sk","--secret_key",action="store", dest="secret_key",help="Secret key.")
PARSER.add_option("-e","--endpoint",action="store", dest="endpoint",help="Enpoint, https://xxx.xxx.xxx, e.g.")
PARSER.add_option("-b","--bucket_name",action="store", dest="bucket_name",help="Bucket name.")
PARSER.add_option("-s","--source_file",action="store", dest="source_file",help="Source file of full list of objects.")
PARSER.add_option("-o","--output_file",action="store", dest="output_file",help="Output file.")
PARSER.add_option("--separate_time","--separate_time",action="store", dest="separate_time",help="Collect object after separate time, 2000-01-01 00:00:00 e.g.")
PARSER.add_option("-t","--thread_num",action="store", dest="thread_num",help="Number of thread(s).")

PARSER.add_option("-w","--workspace_path",action="store",dest="workspace_path",help="Path of workspace, " + WORKSPACE + " by default.")
(options, args) = PARSER.parse_args()

def datetime_string2timestamp_s(datetime_string):
	time_array = time.strptime(datetime_string, "%Y-%m-%d %H:%M:%S")
	timestamp = time.mktime(time_array)
	return int(timestamp)

def datetime_string2timestamp_ms(datetime_string):
	return datetime_string2timestamp_s(datetime_string) * 1000

if options.thread_num:
	THREAD_NUM = options.thread_num

if options.workspace_path:
	WORKSPACE = options.workspace_path

if options.source_file:
	SOURCE_FILE = options.source_file

if options.output_file:
	OUTPUT_FILE = options.output_file

if options.access_key:
	ACCESS_KEY = access_key

if options.secret_key:
	SECRET_KEY = secret_key

if options.endpoint:
	ENDPOINT = options.endpoint

if options.bucket_name:
	BUCKET_NAME = options.bucket_name

if options.separate_time:
	SEPARATE_TIME = datetime_string2timestamp_ms(options.separate_time)

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
	result = queue.get(False)
	lock.release()
	return result

def get_parts_from_line(line):
	parts = line.split()
	time = parts[0]
	length = len(parts)
	key = ""
	for i in range(1, length - 1):
		key += parts[i]
	size = parts[length - 1]
	return time, key, size

def get_line_of_file(source_file):
	c = 0
	with open(file_name) as file:
		for line in file:
			c += 1
	return c

def generate_marker_section(source_file, dictionary, object_count_per_section):
	c = 0
	with open(source_file) as one_file:
		for line in one_file:
			if c % object_count_per_section == 0:
				sys.stdout.write("Procesed lines: " + str(c))
				sys.stdout.write("\r")
				sys.stdout.flush()
				time, key, size = get_parts_from_line(line)
				dictionary[key] = time
			c += 1
	sys.stdout.write("Procesed lines: " + str(c))
	sys.stdout.write("\r")
	sys.stdout.flush()
	print ("\n")

def put_dictionary_into_queue(dictionary, queue, lock):
	for key in dictionary:
		write_queue(queue, lock, key)

def is_time_a_after_b(time_a, time_b):
	return time_a > time_b

def read_object_list(bucket, after_marker, max_keys):
	result = oss2.ObjectIterator(bucket, max_keys=1000, marker=after_marker)
	return islice(result, max_keys)

def format_object(obj):
	last_modified = str(obj.last_modified)
	if len(last_modified) < 13:
		last_modified = str(obj.last_modified) + "000"
	return last_modified  + " " + obj.key + " " + str(obj.size)

def worker(worker_name, dictionary, queue, lock):
	auth = oss2.Auth(ACCESS_KEY, SECRET_KEY)
	bucket = oss2.Bucket(auth, ENDPOINT, BUCKET_NAME)
	key = read_queue(queue, lock)
	after_marker = key
	with open(WORKSPACE + "/" + worker_name, "a") as output_file:
		while True:
			if not key:
				break
			section_result = read_object_list(bucket, after_marker, int(SECTION_SIZE * 1.1))
			after_marker = section_result.next_marker
			for obj in section_result:
				if is_time_a_after_b(obj.last_modified, SEPARATE_TIME) == True:
					output_file.write(format_object(obj))
				if dictionary.has_key(obj.key):
					key = read_queue(queue, lock)
					after_marker = key
					break

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
			output_file.write(generate_line(value.time, key, value.size))
	finally:
		if output_file:
			output_file.close()

if __name__ == '__main__':
	pdb.set_trace()
	if not SOURCE_FILE or not OUTPUT_FILE or not BUCKET_NAME or not ENDPOINT or not ACCESS_KEY or not SECRET_KEY or not SEPARATE_TIME:
		PARSER.print_help()
		sys.exit()	
	time_start = datetime.datetime.now()
	print ("Start time: " + time_start.strftime("%Y-%m-%d %H:%M:%S") + "\n")
	print ("thread_num: " + str(THREAD_NUM) + ", workspace: " + WORKSPACE + ", separate_time: " + str(SEPARATE_TIME) + "(" + timestamp2datetime_string_ms(SEPARATE_TIME) +  ")\n")
	init()
	#with multiprocessing.Manager() as manager:
	#	dictionary = manager.dict()
#		lock = manager.Lock()
#		queue = manager.Queue()
#		pool = Pool()
	dictionary = {}
	lock =threading.Lock()
	queue = Queue.Queue()
	print ("Generating marker sections...\n")
	generate_marker_section(SOURCE_FILE, dictionary, SECTION_SIZE)
	print ("Genarating marker sections finished at: " + datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S") + "\n")
	dictionary[""] = 0
	print ("Putting marker sections into queue...\n")
	put_dictionary_into_queue(dictionary, queue, lock)
	print ("Putting marker sections into queue finished at: " + datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S") + "\n")
	print ("Starting threads...\n")
	worker(APP_PREFIX + str(0), dictionary, queue, lock)
		#for i in range(THREAD_NUM):
		#	pool.apply_async(worker, args=(APP_PREFIX + str(i), dictionary, queue, lock))
		#pool.close()
		#pool.join()
	print ("All thread processing finished at: " + datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S") + "\n")
	print ("Merging files...\n")
	merge_files()
	time_end = datetime.datetime.now()
	print ("Merging finished at: " + datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S") + "\n")
	print ("Time cost: " + str(time_end - time_start) + "ms\n")
	print ("Done!\n")
#		#for b in islice(oss2.ObjectIterator(bucket, max_keys=10, marker='b5/'), 1000):
#	result = oss2.ObjectIterator(bucket, max_keys=10, marker='b5/aliyun-2G@2')
#	part = islice(result, 10000)
#	for b in part:
#		print b.key + " next marker: " + result.next_marker + " is dir: " + str(b.is_prefix()) + " last_modified: " + str(b.last_modified) + " size: " + str(b.size)
#	
#	
#	p =	
