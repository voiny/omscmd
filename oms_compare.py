#!/usr/bin/env python
from optparse import OptionParser
import traceback
import pdb
import threading
import datetime
#import thread
import os
import glob

BIG_DIC = {}
THREADS = []
TMP_WORKSPACE = "/root/omscmd/"
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
PARSER.add_option("-e","--enable_size_comparsion",action="store",dest="size_enable",help="enable size comparsion setting.")
(options, args) = PARSER.parse_args()

DEST_FILE = options.dest_file
SRC_FILE = options.src_file
THREAD_NUM = options.thread_number
SIZE_ENABLE = options.size_enable

def clear_tmp_file():
	if os.path.exists(TMP_WORKSPACE+SUB_FILES_DIR) :
		s_files = glob.glob(TMP_WORKSPACE+SUB_FILES_DIR+"/*")
		for f in s_files:
			os.remove(f)
	else:
		os.mkdir(TMP_WORKSPACE+SUB_FILES_DIR)

	if os.path.exists(TMP_WORKSPACE+RESULT_FILES_DIR) :
		r_files = glob.glob(TMP_WORKSPACE+RESULT_FILES_DIR+"/*")
		for f in r_files:
			os.remove(f)
	else:	
		os.mkdir(TMP_WORKSPACE+RESULT_FILES_DIR)

# load the destfile into dic
def generate_dst_big_dic(destfile):
	try:
		file = open(destfile)
		while 1:
			line = file.readline()
			if not line:	
				break
			else:	
				#for line in lines:
				parts = line.split( )
				time = parts[0]
				name = parts[1]
				size = parts[2]
				if not SIZE_ENABLE or SIZE_ENABLE != "true":
					BIG_DIC[name]=time
				else: 
					BIG_DIC[name+size]=time
	finally:
		if file:
			file.close()


# split srcfile to several sub srcfile
def get_file_total_line_num(file_name):
	i = 0
	try:
		with open(file_name) as file:
			while 1:
				#lines = file.readlines(100)
				line = file.readline()
				if not line:
					break; 
				i = i + 1
	finally:
		if file:
			file.close()
	return i


# split src_file to several sub src_file
def split_file(file_name, split_num):
	total_line_num = get_file_total_line_num(file_name)	
	sub_line = total_line_num/int(split_num) + 1
	sub_file_list =[]
	i = 0
	try:
		with open(file_name) as file:
			while i < int(split_num):
				sub_file_name = TMP_WORKSPACE + SUB_FILES_DIR + SUB_FILE + str(i) + ".txt"
				sub_f = None
				try:
					with open(sub_file_name, 'w') as sub_f:
						for num in range(sub_line):
							line = file.readline()
							if not line:
								break
							else:
								sub_f.write(line)
				finally:
					if sub_f:
						sub_f.close()				
				i += 1
				sub_file_list.append(sub_file_name)
	finally:
		if file:
			file.close()
	return sub_file_list


def compare_object(file_name, dic, num):
	try: 
		sub_diff_file = open(TMP_WORKSPACE + RESULT_FILES_DIR + RESULT_SUB_DIFF_FILE + num +".txt",'w')
		sub_same_file = open(TMP_WORKSPACE + RESULT_FILES_DIR + RESULT_SUB_SAME_FILE + num +".txt",'w')
		try:
			with open(file_name) as tmp_file:
				while 1:
					lines = tmp_file.readlines()
        				if not lines:
                				break
        				for line in lines:
                				parts = line.split( )
						time = parts[0]
                				name = parts[1]
						size = parts[2]
						if not SIZE_ENABLE or SIZE_ENABLE!="true":
							key = name
						else:
							key = name+size
                				#if(dic.has_key(key) and dic[key] < time):
                				if(dic.has_key(key) and time <= dic[key]):
							sub_same_file.write(time + " " + name + " " + size +'\n')
						else:
							sub_diff_file.write(time + " " + name + " " + size +'\n')
		finally:
			if tmp_file:
				tmp_file.close()
	finally:
		pass
		#if tmp_file:
			#tmp_file.close()
		if sub_diff_file:
			sub_diff_file.close()
		if sub_same_file:
			sub_same_file.close()

def combine_result(number):
	try:	
		diff_file = open(TMP_WORKSPACE + RESULT_FILES_DIR + RESULT_DIFF_FILE +".txt",'w')
		same_file = open(TMP_WORKSPACE + RESULT_FILES_DIR + RESULT_SAME_FILE +".txt",'w')
		for i in range(int(number)):
			tmp_sub_diff_file = None;
			tmp_sub_same_file = None;
			try:
				with open(TMP_WORKSPACE + RESULT_FILES_DIR + RESULT_SUB_DIFF_FILE + str(i) +".txt","r") as tmp_sub_diff_file:
					while 1:
						lines = tmp_sub_diff_file.readlines()
						if not lines:
							break
						for line in lines:
							diff_file.write(line)
				with open(TMP_WORKSPACE + RESULT_FILES_DIR + RESULT_SUB_SAME_FILE + str(i) + ".txt","r") as tmp_sub_same_file:
					while 1:
						lines = tmp_sub_same_file.readlines()
						if not lines:
							break
						for line in lines:
							same_file.write(line)
			finally:
				if tmp_sub_diff_file:
					tmp_sub_diff_file.close()
				if tmp_sub_same_file:
					tmp_sub_same_file.close()
	finally:
		if diff_file:
			diff_file.close()
		if same_file:
			same_file.close()

if __name__ == '__main__':
	#pdb.set_trace()
	print str(datetime.datetime.now()) + "   start clearing the tmp dir files ..."
	clear_tmp_file()
	print str(datetime.datetime.now()) + "   start loading the map ..."
	generate_dst_big_dic(DEST_FILE)
	print str(datetime.datetime.now()) + "   finish loading the map ..."
	#compare_object(SRC_FILE,MAP)
#	#thread.start_new_thread(compare_object, (SRC_FILE, MAP))
	sub_files_list = split_file(SRC_FILE, THREAD_NUM)
	print str(datetime.datetime.now()) + "   finish split the src file, with len " + str(len(sub_files_list)) + "..."
	
	for i in range(len(sub_files_list)):
		t = threading.Thread(target=compare_object, args=(TMP_WORKSPACE+SUB_FILES_DIR+SUB_FILE+str(i)+".txt", BIG_DIC, str(i)))
		print str(datetime.datetime.now()) + "   thread "+str(i)+" finish initiating ..."
		THREADS.append(t)
	
	print str(datetime.datetime.now()) + "   finish initiating the thead ..."
	for j in range(len(THREADS)):
		THREADS[j].start()
		print str(datetime.datetime.now()) + "   thread "+str(j)+ " finish starting..."
	
	print str(datetime.datetime.now()) + "   finish starting the thread ..."
	for k in THREADS:
		k.join()
	print str(datetime.datetime.now()) + "   finish comparing object ..."
	combine_result(len(THREADS))
	print str(datetime.datetime.now()) + "   finish combining result sub files ..."
	BIG_DIC.clear()
	print str(datetime.datetime.now()) + "   finish clearing big dic ..."
#	try:
#		sys.exit()
#	except:
#		pass

