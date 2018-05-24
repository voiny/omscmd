#!/usr/bin/env python
from optparse import OptionParser
import sys
import traceback
import pdb
import threading
import datetime
#import thread
import os
import glob

BIG_DIC = {}
THREADS = []
TMP_WORKSPACE = "/data/tmp/omscompare/"
SUB_FILES_DIR = "sub_files/"
SUB_FILE = "sub_file"
RESULT_FILES_DIR = "result_files/"
RESULT_SUB_DIFF_FILE = "result_sub_diff_file"
RESULT_SUB_SAME_FILE = "result_sub_same_file"
RESULT_DIFF_FILE = "result_diff_file"
RESULT_SAME_FILE = "result_same_file"

PARSER = OptionParser()
PARSER.add_option("-s","--src_file",action="store", dest="src_file",help="write oss src file path.")
PARSER.add_option("-d","--dest_file",action="store",dest="dest_file",help="write obs dest file path.")
PARSER.add_option("-n","--thread_number",action="store",dest="thread_number",help="write current thread number.")
PARSER.add_option("-e","--enable_size_comparison",action="store_true",default=False, dest="size_enable",help="enable size comparison setting.")
PARSER.add_option("-t","--enable_time_comparison",action="store_true",default=False, dest="time_enable",help="enable time comparison setting.")
PARSER.add_option("-w","--workspace_path",action="store",dest="workspace_path",help="path of workspace, " + TMP_WORKSPACE + " by default.")
(options, args) = PARSER.parse_args()

DEST_FILE = options.dest_file
SRC_FILE = options.src_file
THREAD_NUM = options.thread_number
SIZE_ENABLE = options.size_enable
TIME_ENABLE = options.time_enable

if options.workspace_path:
	TMP_WORKSPACE = options.workspace_path

def clear_tmp_file():
	if os.path.exists(TMP_WORKSPACE+SUB_FILES_DIR) :
		s_files = glob.glob(TMP_WORKSPACE+SUB_FILES_DIR+"/*")
		for f in s_files:
			os.remove(f)
	else:
		os.makedirs(TMP_WORKSPACE+SUB_FILES_DIR)

	if os.path.exists(TMP_WORKSPACE+RESULT_FILES_DIR) :
		r_files = glob.glob(TMP_WORKSPACE+RESULT_FILES_DIR+"/*")
		for f in r_files:
			os.remove(f)
	else:	
		os.makedirs(TMP_WORKSPACE+RESULT_FILES_DIR)

def get_parts_from_line(line):
	parts = line.split()
	time = parts[0]
	length = len(parts)
	key = ""
	for i in range(1, length - 1):
		key += parts[i] 
		key += " "
	if len(key) > 0:
		key = key[:-1]
	size = parts[length - 1]
	return time, key, size

# load the destfile into dic
def generate_dst_big_dic(destfile):
	with open(destfile) as file:
		for line in file:
			time, name, size = get_parts_from_line(line)
			if SIZE_ENABLE != True:
				BIG_DIC[name]=time
			else: 
				BIG_DIC[name+size]=time

# split srcfile to several sub srcfile
def get_file_total_line_num(file_name):
	i = 0
	with open(file_name) as file:
		for line in file:
			i = i + 1
	return i

# split src_file to several sub src_file
def split_file(file_name, split_num):
	total_line_num = get_file_total_line_num(file_name)	
	sub_line = total_line_num/int(split_num) + 1
	sub_file_list =[]
	i = 0
	with open(file_name) as file:
		while i < int(split_num):
			sub_file_name = TMP_WORKSPACE + SUB_FILES_DIR + SUB_FILE + str(i) + ".txt"
			with open(sub_file_name, 'w') as sub_f:
				for num in range(sub_line):
					line = file.readline()
					if not line:
						break
					else:
						sub_f.write(line)
			i += 1
			sub_file_list.append(sub_file_name)
	return sub_file_list

def compare_object(file_name, dic, num, compare_time = False):
	sub_diff_file = None
	sub_same_file = None
	try: 
		sub_diff_file = open(TMP_WORKSPACE + RESULT_FILES_DIR + RESULT_SUB_DIFF_FILE + num +".txt",'w')
		sub_same_file = open(TMP_WORKSPACE + RESULT_FILES_DIR + RESULT_SUB_SAME_FILE + num +".txt",'w')
		with open(file_name) as tmp_file:
			if compare_time == False:
				for line in tmp_file:
					time, name, size = get_parts_from_line(line)
					if SIZE_ENABLE != True:
						key = name
					else:
						key = name+size
        				if(dic.has_key(key)):
						sub_same_file.write(time + " " + name + " " + size +'\n')
					else:
						sub_diff_file.write(time + " " + name + " " + size +'\n')
			else:
				for line in tmp_file:
					time, name, size = get_parts_from_line(line)
					if SIZE_ENABLE != True:
						key = name
					else:
						key = name+size
        				if(dic.has_key(key) and time <= dic[key]):
						sub_same_file.write(time + " " + name + " " + size +'\n')
					else:
						sub_diff_file.write(time + " " + name + " " + size +'\n')
	finally:
		if sub_diff_file:
			sub_diff_file.close()
		if sub_same_file:
			sub_same_file.close()
	print("thread-" + str(num) + " exited.\n")

def combine_result(number):
	diff_file = None
	same_file = None
	try:	
		diff_file = open(TMP_WORKSPACE + RESULT_FILES_DIR + RESULT_DIFF_FILE,'w')
		same_file = open(TMP_WORKSPACE + RESULT_FILES_DIR + RESULT_SAME_FILE,'w')
		for i in range(int(number)):
			tmp_sub_diff_file = None;
			tmp_sub_same_file = None;
			with open(TMP_WORKSPACE + RESULT_FILES_DIR + RESULT_SUB_DIFF_FILE + str(i) +".txt","r") as tmp_sub_diff_file:
				for line in tmp_sub_diff_file:
					diff_file.write(line)
			with open(TMP_WORKSPACE + RESULT_FILES_DIR + RESULT_SUB_SAME_FILE + str(i) + ".txt","r") as tmp_sub_same_file:
				for line in tmp_sub_same_file:
					same_file.write(line)
	finally:
		if diff_file:
			diff_file.close()
		if same_file:
			same_file.close()

if __name__ == '__main__':
#	pdb.set_trace()
	if not DEST_FILE or not SRC_FILE or not THREAD_NUM:
		PARSER.print_help()
		sys.exit()
	print str(datetime.datetime.now()) + "   start clearing the tmp dir files ..."
	clear_tmp_file()
	print str(datetime.datetime.now()) + "   start loading the map ..."
	generate_dst_big_dic(DEST_FILE)
	print str(datetime.datetime.now()) + "   finish loading the map ..."
	sub_files_list = split_file(SRC_FILE, THREAD_NUM)
	print str(datetime.datetime.now()) + "   finish split the src file, with len " + str(len(sub_files_list)) + "..."
	
#	compare_object(TMP_WORKSPACE+SUB_FILES_DIR+SUB_FILE+str(0)+".txt", BIG_DIC, str(0), TIME_ENABLE)
	for i in range(len(sub_files_list)):
		t = threading.Thread(target=compare_object, args=(TMP_WORKSPACE+SUB_FILES_DIR+SUB_FILE+str(i)+".txt", BIG_DIC, str(i), TIME_ENABLE))
		print str(datetime.datetime.now()) + "   thread "+str(i)+" finish initiating ..."
		THREADS.append(t)
	
	print str(datetime.datetime.now()) + "   finish initiating the thread ..."
	for j in range(len(THREADS)):
		THREADS[j].start()
		print str(datetime.datetime.now()) + "   thread "+str(j)+ " finish starting..."
	
	print str(datetime.datetime.now()) + "   finish starting the thread ..."
	for k in THREADS:
		k.join()
	print str(datetime.datetime.now()) + "   finish comparing object ..."
	combine_result(len(THREADS))
	print str(datetime.datetime.now()) + "   finish combining result sub files ..."
	print "Output file location: " + TMP_WORKSPACE
	BIG_DIC.clear()
	print str(datetime.datetime.now()) + "   finish clearing big dic ..."
	try:
		sys.exit()
		print "Exited.\n"
	except:
		pass

