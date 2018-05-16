#!/usr/bin/env python

import oss2
import pdb
from optparse import OptionParser
from itertools import islice

APP_PREFIX = "quick_compare"
THREAD_NUM = 1
MAX_KEYS = 1000
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
PARSER.add_option("--sk","--secret_key",action="store", dest="secrete_key",help="Secret key.")
PARSER.add_option("-e","--endpoint",action="store", dest="endpoint",help="Enpoint, https://xxx.xxx.xxx, e.g.")
PARSER.add_option("-b","--bucket_name",action="store", dest="bucket_name",help="Bucket name.")
PARSER.add_option("-s","--source_file",action="store", dest="source_file",help="Source file of full list of objects.")
PARSER.add_option("-o","--output_file",action="store", dest="output_file",help="Output file.")
PARSER.add_option("--separate_time","--separate_time",action="store", dest="separate_time",help="Collect object after separate time, 1234567890123 e.g.")
PARSER.add_option("-t","--thread_num",action="store", dest="thread_num",help="Number of thread(s).")

PARSER.add_option("-w","--workspace_path",action="store",dest="workspace_path",help="Path of workspace, " + WORKSPACE + " by default.")
(options, args) = PARSER.parse_args()

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
	SEPARATE_TIME = options.separate_time

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
	result = queue.get(False)
	lock.release()
	return result

def get_parts_from_line(line):
	parts = line.split()
	time = parts[0]
	length = len(parts)
	key = None
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
				time, key, size = get_parts_from_line(line)
				dictionary[key] = time
			c += 1

def put_dictionary_into_queue(dictionary, queue, lock):
	for key in dictionary:
		write_queue(queue, lock, key)

def is_time_a_after_b(time_a, time_b):
	return time_a > time_b

def read_object_list(bucket, after_marker, max_keys):
	result = oss2.ObjectIterator(bucket, max_keys=max_keys, marker=after_marker)
	return islice(result, max_keys)

def format_object(obj):
	last_modified = str(obj.last_modified)
	if len(last_modified) < 13:
		last_modified = str(obj.last_modified) + "000"
	return last_modified  " " + obj.key + " " + str(obj.size)

def worker(worker_name, dictionary, queue, lock):
	auth = oss2.Auth(ACCESS_KEY, SECRET_KEY)
	bucket = oss2.Bucket(auth, ENDPOINT, BUCKET_NAME)
	key = read_queue(queue, lock)
	after_marker = key
	with open(WORKSPACE + "/" + worker_name, "a") as output_file
		while True:
			if not key:
				break
			section_result = read_object_list(bucket, after_marker, MAX_KEYS)
			after_marker = section_result.next_marker
			for obj in section_result:
				if is_time_a_after_b(obj.last_modified, SEPARATE_TIME) == True:
					output_file.write(format_object(obj))
				if dictionary.has_key(obj.key):
					key = read_queue(queue, lock)
					after_marker = key

def merge_files(): 
	try:
		output_file = open(OUTPUT_FILE, "w")
		for i in range(THREAD_NUM):
			# number of thread stars from 0
			subfile = WORKSPACE + "/" + APP_PREFIX + str(i)
			with open(subfile, "r") as one_subfile:
				for line in one_subfile:
					output_file.write(line)
	finally:
		if output_file:
			output_file.close()

if __name__ == '__main__':
	pdb.set_trace()
	if not SOURCE_FILE or not OUTPUT_FILE or not BUCKET_NAME or not ENDPOINT or not ACCESS_KEY or not SECRET_KEY or not SEPARATE_TIME:
		PARSER.print_help()
		sys.exit()	
	print ("thread_num: " + str(THREAD_NUM) + ", workspace: " + WORKSPACE + "\n")
	init()
	with multiprocessing.Manager() as manager:
		dictionary = manager.dict()
		generate_marker_section(SOURCE_FILE, dictionary, 100)
		dictionary[""] = True
		put_dictionary_into_queue(dictionary, queue, lock)
		queue = manager.Queue()
		lock = manager.Lock()
		pool = Pool()
		for i in range(THREAD_NUM):
			pool.apply_async(worker, args=(APP_PREFIX + str(i), dictionary, queue, lock))
		pool.close()
		pool.join()
	merge_files()
		#for b in islice(oss2.ObjectIterator(bucket, max_keys=10, marker='b5/'), 1000):
	result = oss2.ObjectIterator(bucket, max_keys=10, marker='b5/aliyun-2G@2')
	part = islice(result, 10000)
	for b in part:
		print b.key + " next marker: " + result.next_marker + " is dir: " + str(b.is_prefix()) + " last_modified: " + str(b.last_modified) + " size: " + str(b.size)
	
	
	p =	
