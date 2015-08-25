#!/usr/bin/env python

import sys
import csv
import errno

csv.field_size_limit(sys.maxsize)  # Or else it cannot handle fields longer than 131072

tabin = csv.reader(sys.stdin, dialect=csv.excel)
commaout = csv.writer(sys.stdout, dialect=csv.excel_tab, lineterminator='\n')

try:
  for row in tabin:
    # HACK: Replace newlines in fields with "|". tsv has no good support for fields containing
    # newlines; excel and google sheets convert them to spaces and do *not* quote the field, unlike
    # for csv. Python's csv library just treats them as normal characters and thus breaks the
    # format. Even if it quoted the newline-containing field, it would be nightmarish to deal with
    # those later.
    row = [field.replace('\n','|') for field in row]  
    commaout.writerow(row)
except IOError as e:
  if e.errno == errno.EPIPE:
    pass
  else:
    raise
