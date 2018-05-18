#!/usr/bin/env python

import oss2
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

APP_PREFIX = "quick_compare"
THREAD_NUM = 1
#the number of keys that a section contains
SECTION_SIZE = 10000
WORKSPACE = "/data/tmp/quick_compare"
SOURCE_FILE = None
OUTPUT_FILE = None
BUCKET_NAME = "perftest2"
SEPARATE_TIME = None
ENDPOINT = "oss-cn-beijing.aliyuncs.com"
ACCESS_KEY = "LTAI4uUTSs8oJFNO"
SECRET_KEY = "6h9axkuayKvJGK7gTSdhE87Mwal41I"
PARSER = OptionParser()
PARSER.add_option("--ak", "--access_key",action="store", dest="access_key",help="Access key.")
PARSER.add_option("--sk", "--secret_key",action="store", dest="secret_key",help="Secret key.")
PARSER.add_option("-e", "--endpoint",action="store", dest="endpoint",help="Enpoint, https://xxx.xxx.xxx, e.g.")
PARSER.add_option("-b", "--bucket_name",action="store", dest="bucket_name",help="Bucket name.")
PARSER.add_option("-s", "--source_file",action="store", dest="source_file",help="Source file of full list of objects.")
PARSER.add_option("-o", "--output_file",action="store", dest="output_file",help="Output file.")
PARSER.add_option("--separate_time", "--separate_time",action="store", dest="separate_time",help="Collect object after separate time, '2000-01-01 00:00:00' e.g.")
PARSER.add_option("--section_size", "--section_size",action="store", type="int", dest="section_size",help="Section size, " + str(SECTION_SIZE) + " by default.")
PARSER.add_option("-t", "--thread_num",action="store", type="int", dest="thread_num",help="Number of thread(s).")

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

if options.section_size:
	SECTION_SIZE = options.section_size

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
	result = None
	try:
		result = queue.get(False)
	except:
		result = None
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
				sys.stdout.write("Processed lines: " + str(c))
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
	for key in dictionary.keys():
		write_queue(queue, lock, key)

def is_time_a_after_b(time_a, time_b):
	return time_a > time_b

def read_object_list(bucket, after_marker, input_max_keys):
	real_max_keys = input_max_keys
	if (input_max_keys > 1000):
		real_max_keys = 1000
	result = oss2.ObjectIterator(bucket, max_keys=real_max_keys, marker=after_marker)
	return result, islice(result, input_max_keys)

def format_object(obj):
	last_modified = str(obj.last_modified)
#	if len(last_modified) < 13:
#		last_modified = str(obj.last_modified) + "000"
	return last_modified  + "000 " + obj.key + " " + str(obj.size)

def worker(worker_name, dictionary, queue, lock):
	auth = oss2.Auth(ACCESS_KEY, SECRET_KEY)
	bucket = oss2.Bucket(auth, ENDPOINT, BUCKET_NAME)
	key = read_queue(queue, lock)
	after_marker = key
	arrive_end_and_need_to_change_after_marker = False
	print ("Worker: " + worker_name + " started.")
	with open(WORKSPACE + "/" + worker_name, "a") as output_file:
		#print ("key: " + key)
		got_empty_return = False
		separate_time = SEPARATE_TIME / 1000
		while True:
			if key == None:
				break
			print ("Read round, after_marker: " + after_marker + " -----------------------------------------------")
			if arrive_end_and_need_to_change_after_marker == True:
				arrive_end_and_need_to_change_after_marker = False
				key = read_queue(queue, lock)
				after_marker = key
				if after_marker == None:
					break
				print ("after_marker is forced to be changed into: " + after_marker + " -----------------------------------------------")
			if got_empty_return == True:
				key = read_queue(queue, lock)
				after_marker = key
				got_empty_return = False
			original_result, section_result = read_object_list(bucket, after_marker, int(SECTION_SIZE * 1.1))
			after_marker = original_result.next_marker
			count = 0
			for obj in section_result:
				count += 1
				after_marker = original_result.next_marker
				if after_marker == "":
					arrive_end_and_need_to_change_after_marker = True
				#print ("after_marker check: " + after_marker)
				has = False
				if is_time_a_after_b(obj.last_modified, separate_time) == True:
					line = format_object(obj)
					output_file.write(line + "\n")
					#print ("write true line: " + line)
				if dictionary.has_key(obj.key):
					arrive_end_and_need_to_change_after_marker = False
					key = read_queue(queue, lock)
					after_marker = key
					if key == None:
						break
					print ("has_key, read_queue: " +obj.key + ", after_marker becomes " + key)
					break
				#print (worker_name + " after_marker: " + after_marker + ", key: " + obj.key + ", has: " + str(has))
			if count == 0:
				got_empty_return = True
				print("got empty return.")
			else:
				got_empty_return = False
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
	if not SOURCE_FILE or not OUTPUT_FILE or not BUCKET_NAME or not ENDPOINT or not ACCESS_KEY or not SECRET_KEY or not SEPARATE_TIME:
		PARSER.print_help()
		sys.exit()	
	time_start = datetime.datetime.now()
	print ("Start time: " + time_start.strftime("%Y-%m-%d %H:%M:%S") + "\n")
	print ("thread_num: " + str(THREAD_NUM) + ", workspace: " + WORKSPACE + ", separate_time: " + str(SEPARATE_TIME) + "(" + timestamp2datetime_string_ms(SEPARATE_TIME) +  ")\n")
	init()
	with multiprocessing.Manager() as manager:
		dictionary = manager.dict()
		lock = manager.Lock()
		queue = manager.Queue()
		pool = Pool(THREAD_NUM)
		print ("Generating marker sections...\n")
		generate_marker_section(SOURCE_FILE, dictionary, SECTION_SIZE)
		print ("Genarating marker sections finished at: " + datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S") + "\n")
		dictionary[""] = 0
		print ("Putting marker sections into queue...\n")
		put_dictionary_into_queue(dictionary, queue, lock)
		print ("Putting marker sections into queue finished at: " + datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S") + "\n")
		print ("Starting threads...\n")
		for i in range(THREAD_NUM):
			pool.apply_async(worker, args=(APP_PREFIX + str(i), dictionary, queue, lock))
		pool.close()
		pool.join()
	print ("All thread processing finished at: " + datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S") + "\n")
	print ("Merging files...\n")
	merge_files()
	time_end = datetime.datetime.now()
	print ("Merging finished at: " + datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S") + "\n")
	print ("Time cost: " + str(time_end - time_start) + "ms\n")
	print ("Done!\n")

def test2():
	if not SOURCE_FILE or not OUTPUT_FILE or not BUCKET_NAME or not ENDPOINT or not ACCESS_KEY or not SECRET_KEY or not SEPARATE_TIME:
		PARSER.print_help()
		sys.exit()	
	time_start = datetime.datetime.now()
	print ("Start time: " + time_start.strftime("%Y-%m-%d %H:%M:%S") + "\n")
	print ("thread_num: " + str(THREAD_NUM) + ", workspace: " + WORKSPACE + ", separate_time: " + str(SEPARATE_TIME) + "(" + timestamp2datetime_string_ms(SEPARATE_TIME) +  ")\n")
	init()
	with multiprocessing.Manager() as manager:
		#dictionary = manager.dict()
		dictionary = {}
		lock = manager.Lock()
		queue = manager.Queue()
		pool = Pool()
		print ("Generating marker sections...\n")
		generate_marker_section(SOURCE_FILE, dictionary, SECTION_SIZE)
		print ("Genarating marker sections finished at: " + datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S") + "\n")
		dictionary[""] = 0
		print ("Putting marker sections into queue...\n")
		put_dictionary_into_queue(dictionary, queue, lock)
		print ("Putting marker sections into queue finished at: " + datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S") + "\n")
		print ("Starting threads...\n")
		worker(APP_PREFIX + str(0), dictionary, queue, lock)
	print ("All thread processing finished at: " + datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S") + "\n")
	print ("Merging files...\n")
	merge_files()
	time_end = datetime.datetime.now()
	print ("Merging finished at: " + datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S") + "\n")
	print ("Time cost: " + str(time_end - time_start) + "ms\n")
	print ("Done!\n")

def test():
	try:
		auth = oss2.Auth(ACCESS_KEY, SECRET_KEY)
		bucket = oss2.Bucket(auth, ENDPOINT, BUCKET_NAME)
		#result, part = read_object_list(bucket, "fdsaf", 1)
		result, part = read_object_list(bucket, "cdv-diandian/DDSP_YUNSHI/7353/1937813ce5eb40e599b1736378509c5a.jpg", 1)
		#result = oss2.ObjectIterator(bucket, max_keys=2, marker='')
		#part = islice(result, 3)
		print ("nextmarker: " + result.next_marker)
		for b in part:
			print b.key + " next marker: " + result.next_marker + " is dir: " + str(b.is_prefix()) + " last_modified: " + str(b.last_modified) + " size: " + str(b.size)
	except:
		print("err")

if __name__ == '__main__':
	#pdb.set_trace()
	main()
