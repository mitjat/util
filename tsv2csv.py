#!/usr/bin/env python

import sys
import csv
import errno

csv.field_size_limit(sys.maxsize)  # Or else it cannot handle fields longer than 131072

tabin = csv.reader(sys.stdin, dialect=csv.excel_tab)
commaout = csv.writer(sys.stdout, dialect=csv.excel, lineterminator='\n')

try:
  for row in tabin:
    commaout.writerow(row)
except IOError as e:
  if e.errno == errno.EPIPE:
    pass
  else:
    raise
