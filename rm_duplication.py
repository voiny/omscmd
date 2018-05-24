#!/usr/bin/env python
from optparse import OptionParser
import sys
import traceback
import pdb
import threading
import datetime
import os

BIG_DIC = {}
THREADS = []

PARSER = OptionParser()
PARSER.add_option("-s","--source_file",action="store", dest="source",help="source")
PARSER.add_option("-o","--output_file",action="store",dest="output",help="output")
(options, args) = PARSER.parse_args()

SOURCE = options.source
OUTPUT = options.output

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

def generate_big_dic(file_path):
	with open(file_path) as file:
		for line in file:
			time, name, size = get_parts_from_line(line)	
			parts = [time, name, size]
			store = None
			if name in BIG_DIC:
				store = BIG_DIC[name]
			if store == None:
				BIG_DIC[name] = parts
			else:
				if (time > store[0]):
					BIG_DIC[name] = parts

def output_result(output):
	with open(output, "w") as output_file:
		for value in BIG_DIC.values():
			time = value[0]
			name = value[1]
			size = value[2]
			if not time or not name or not size:
				print ("Failed to load key: " + name)
				continue
			output_file.write(time + " " + name + " " + size + "\n")

if __name__ == '__main__':
	#pdb.set_trace()
	if not SOURCE or not OUTPUT:
		PARSER.print_help()
		sys.exit()
	print str(datetime.datetime.now()) + "   loading data into memory ..."
	generate_big_dic(SOURCE)
	print str(datetime.datetime.now()) + "   outputing ..."
	output_result(OUTPUT)
	print str(datetime.datetime.now()) + "   clearing big dic ..."
	BIG_DIC.clear()

