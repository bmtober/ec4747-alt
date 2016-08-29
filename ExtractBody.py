#!/usr/bin/python

import email.parser 
import os, sys, stat
import shutil

filename = sys.argv[1]
if not os.path.exists(filename): # dest path doesnot exist
	print "ERROR: input file does not exist:", filename
	os.exit(1)
fp = open(filename)
msg = email.message_from_file(fp)
payload = msg.get_payload()
if type(payload) == type(list()) :
	payload = payload[0] # only use the first part of payload
if type(payload) != type('') :
	payload = str(payload)
print payload

