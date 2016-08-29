#!/usr/bin/python

import email.parser 
import os, sys, stat
import shutil

filename = sys.argv[1]
if not os.path.exists(filename):
	print "ERROR: input file does not exist:", filename
	os.exit(1)
fp = open(filename)
msg = email.message_from_file(fp)
subj = msg.get('subject')
subj = str(subj)
print subj

