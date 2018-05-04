#!/usr/bin/env python
from optparse import OptionParser
import traceback
import pdb
import threading
import datetime
import thread

BIG_DIC = {}
THREADS = []
TMP_WORKSPACE = "/tmp/langyu/"
SUB_FILES_DIR = "sub_files/"
SUB_FILE = "sub_file"
RESULT_FILES_DIR = "result_files/"
RESULT_SUB_FILE = "result_sub_file"
RESULT_SUB_SAME_FILE = "result_same_file"


PARSER = OptionParser()
PARSER.add_option("-s","--src_file",action="store", dest="src_file",help="write oss src file path.")
PARSER.add_option("-d","--dest_file",action="store",dest="dest_file",help="write obs dest file path.")
PARSER.add_option("-n","--thread_number",action="store",dest="thread_number",help="write current thread number.")
(options, args) = PARSER.parse_args()

DEST_FILE = options.dest_file
SRC_FILE = options.src_file
THREAD_NUM = options.thread_number

# load the destfile into dic
def generate_dst_big_dic(destfile):
	try:
		file = open(destfile)
		while 1:
			#lines = file.readlines()
			line = file.readline()
			if not line:	
				break
			else:	
				#for line in lines:
				parts = line.split( )
				name = parts[len(parts)-1]
				size = parts[len(parts)-2]
				BIG_DIC[name]=size
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
				try:
					with open(sub_file_name, 'w') as sub_file:
						for num in range(sub_line):
							line = file.readline()
							if not line:
								break
							else:
								sub_file.write(line)
				finally:
					if sub_file:
						sub_file.close()				
				i += 1
				sub_file_list.append(sub_file_name)
	finally:
		if file:
			file.close()
	return sub_file_list


def compare_object(file_name, dic, num):
	try: 
		sub_diff_file = open(TMP_WORKSPACE + RESULT_FILES_DIR + RESULT_SUB_FILE + num +".txt",'w')
		sub_same_file = open(TMP_WORKSPACE + RESULT_FILES_DIR + RESULT_SUB_SAME_FILE + num +".txt",'w')
		try:
			with open(file_name) as tmp_file:
				while 1:
					lines = tmp_file.readlines()
        				if not lines:
                				break
        				for line in lines:
                				parts = line.split( )
                				name = parts[len(parts)-1]
                				if(dic.has_key(name)):
							sub_same_file.write(name+'\n')
						else:
							sub_diff_file.write(name+'\n')
		finally:
			if tmp_file:
				tmp_file.close()
	finally:
		pass
		#if tmp_file:
			#tmp_file.close()
		#if sub_diff_file:
			#sub_diff_file.close()
		#if sub_same_file:
			#sub_same_file.close()


if __name__ == '__main__':
	#pdb.set_trace()
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
	BIG_DIC.clear()
	print str(datetime.datetime.now()) + "   finish clearing big dic ..."
#	try:
#		sys.exit()
#	except:
#		pass

'''
#	print MAP.keys()
#	print MAP.values()
#	print get_file_line_num(DEST_FILE)
#	list =  split_file(SRC_FILE,3)	'
	t = threading.Thread(target=compare_object, args=(SRC_FILE, MAP))
	THREADS.append(t)
	for t in THREADS:
		t.start()

	for t in THREADS:
		t.join()
'''
