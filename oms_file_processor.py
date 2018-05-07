#!/usr/bin/env python
from optparse import OptionParser
import traceback
import pdb
import threading
import datetime
import thread

THREADS = []
TMP_WORKSPACE = "/tmp/langyu/"
SUB_FILES_DIR = "sub_files/"
SUB_FILE = "sub_file"
RESULT_FILES_DIR = "result_files/"
RESULT_SUB_DIFF_FILE = "result_diff_file"
RESULT_SUB_SAME_FILE = "result_same_file"


PARSER = OptionParser()
PARSER.add_option("-s","--src_file",action="store", dest="src_file",help="write oss src file path.")
PARSER.add_option("-d","--dest_file",action="store",dest="dest_file",help="write obs dest file path.")
(options, args) = PARSER.parse_args()

DEST_FILE = options.dest_file
SRC_FILE = options.src_file

# load the destfile into dic
def modify_file(src_file, dest_file):
	try:
		s_file = open(TMP_WORKSPACE + src_file, 'r')
		d_file = open(TMP_WORKSPACE + dest_file, 'w')
		while 1:
			line = s_file.readline()
			if not line:	
				break
			else:	
				parts = line.split( )
				name = parts[len(parts)-1]
				size = parts[len(parts)-4]
				time = parts[0]
				d_file.write(str(time) + "  " + str(name) + "  "+str(size) +"\n")
	finally:
		if s_file:
			s_file.close()
		if d_file:
			d_file.close()


if __name__ == '__main__':
	#pdb.set_trace()
	print str(datetime.datetime.now()) + "   start loading the map ..."
	modify_file(SRC_FILE, DEST_FILE)	
	print str(datetime.datetime.now()) + "   finish loading the map ..."
	
#	try:
#		sys.exit()
#	except:
#		pass

