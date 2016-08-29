#!/usr/bin/python
# FileName: Subsampling.py 
# Version 1.0 by Tao Ban, 2010.5.26
# This function extract all the contents, ie subject and first part from the .eml file 
# and store it in a new file with the same name in the dst dir. 

import email.parser 
import os, sys, stat
import shutil

def ExtractSubPayload (filename):
	''' Extract the subject and payload from the .eml file.
	
	'''
	if not os.path.exists(filename): # dest path doesnot exist
		print "ERROR: input file does not exist:", filename
		os.exit(1)
	fp = open(filename)
	msg = email.message_from_file(fp)
	payload = msg.get_payload()
	if type(payload) == type(list()) :
		payload = payload[0] # only use the first part of payload
	subj = msg.get('subject')
	subj = str(subj)
	if type(payload) != type('') :
		payload = str(payload)
	
	return subj, payload


file = sys.argv[1]

srcdir = sys.argv[2]
if not os.path.exists(srcdir):
	print 'The source directory %s does not exist, exit...' % (srcdir)
	sys.exit()

# dstdirsubj is the directory where the content .eml are stored
dstdirsubj = sys.argv[3]
if not os.path.exists(dstdirsubj):
	print 'The destination directory is newly created.'
	os.makedirs(dstdirsubj)

# dstdirbody is the directory where the content .eml are stored
dstdirbody = sys.argv[4]
if not os.path.exists(dstdirbody):
	print 'The destination directory is newly created.'
	os.makedirs(dstdirbody)

###################################################################
ExtractBodyFromDir ( file, srcdir, dstdirsubj, dstdirbody ) 

