#!/usr/bin/env python
#Get object list by given time section (from start_time to end_time)

from optparse import OptionParser
import sys
import traceback
import pdb
import threading
import datetime
import time
import os

BIG_DIC = {}
THREADS = []

PARSER = OptionParser()
PARSER.add_option("-s","--source_file",action="store", dest="source",help="source")
PARSER.add_option("--start","--start-time",action="store", dest="start_time",help="Example: '2000-01-01 00:00:00'")
PARSER.add_option("--end","--end-time",action="store", dest="end_time",help="Example: '2000-01-01 00:00:00'")
PARSER.add_option("-o","--output_file",action="store",dest="output",help="output")
(options, args) = PARSER.parse_args()

def datetime_string2timestamp_s(datetime_string, datetime_format):
        time_array = time.strptime(datetime_string, datetime_format)
        timestamp = time.mktime(time_array)
        return int(timestamp)

def datetime_string2timestamp_ms(datetime_string, datetime_format):
        return datetime_string2timestamp_s(datetime_string, datetime_format) * 1000

SOURCE = options.source
if options.start_time:
	START_TIME = datetime_string2timestamp_ms(options.start_time, "%Y-%m-%d %H:%M:%S")
if options.end_time:
	END_TIME = datetime_string2timestamp_ms(options.end_time, "%Y-%m-%d %H:%M:%S")
OUTPUT = options.output

def get_parts_from_line(line):
        parts = line.split()
        t = parts[0]
        length = len(parts)
        key = ""
        for i in range(1, length - 1):
                key += parts[i]
        size = parts[length - 1]
        return long(t), key, int(size)

def generate_big_dic(file_path):
	with open(file_path) as file:
		for line in file:
			t, name, size = get_parts_from_line(line)	
			parts = [t, name, size]
			if t >= START_TIME and t <= END_TIME:
				BIG_DIC[name] = parts

def output_result(output):
	with open(output, "w") as output_file:
		for value in BIG_DIC.values():
			t = value[0]
			name = value[1]
			size = value[2]
			if not t or not name or not size:
				print ("Failed to load key: " + name)
				continue
			output_file.write(str(t) + " " + name + " " + str(size) + "\n")

if __name__ == '__main__':
	#pdb.set_trace()
	if not SOURCE or not OUTPUT or not options.start_time or not options.end_time:
		PARSER.print_help()
		sys.exit()
	print str(datetime.datetime.now()) + "   loading data into memory ..."
	generate_big_dic(SOURCE)
	print str(datetime.datetime.now()) + "   outputing ..."
	output_result(OUTPUT)
	print str(datetime.datetime.now()) + "   clearing big dic ..."
	BIG_DIC.clear()

