#!/usr/bin/env python

"""
(Stratified) sampling without replacement of lines on stdin.
Preserves random N lines of input (without replacement), discards others.
Optionally, lines can be grouped into classes based on a value extracted from the line;
in this case, N lines per group are preserved.
Order is not preserved.

Examples:
  sample.py -n100  # 100 samples
  sample.py -n10 -k2  # 10 sample lines for each distinct value fo second column in a tab-separated input
  sample.py -n10 -k 'len(line)' # 10 sample lines for each line length
"""

import os
import sys
from collections import defaultdict
from argparse import ArgumentParser
import random

class ReservoirSample:
  """
  Reservoir sampling. Creates a sample of size `size`; access it via the `result` attribute.
  """
  def __init__(self, size):
    self.size = size  # output sample size
    self.seen = 0  # number of elements considered so far
    self.result = []

  def add(self, el):
    self.seen += 1
    if len(self.result) < self.size:
      self.result.append((self.seen, el))
    else:
      s = random.randint(0, self.seen-1)
      if s < self.size:
        self.result[s] = (self.seen, el)

  def __repr__(self):
    return 'ReservoirSample(size=%r, seen=%r, result=%r)' % (self.size, self.seen, self.result) 

if __name__ == '__main__':
  # Parse command-line params
  arg_parser = ArgumentParser(__doc__)
  arg_parser.add_argument('-n', metavar="NUM", type=int, required=True,
                          help="Number of samples per class.")
  arg_parser.add_argument('-H', '--keep_headers', action="store_true", default=False,
                          help="Input data has headers -- retain first row on the output verbatim.")
  arg_parser.add_argument('-k', '--class_expr', metavar="COL|EXPR", default=None,
                          help="How to extract the class. If this is a comma-separated list of ints, assume input is tab-separated and "
                          "use those columns (1-based) as class. Otherwise, the argument is treated as a python expression that is passed through "
                          "eval(); the variable `line` will hold the current line during evaluation, and `cols` will hold its tab-separated "
                          "columns. Default: don't extract the class.")
  arg_parser.add_argument('--min_class_size', metavar="NUM", type=int, default=0,
                          help="Ignore classes with fewer than this many lines. Default: 0")
  args = arg_parser.parse_args()

  # Parse command-line args
  if args.class_expr == None:
    class_expr = 'None'
  elif all(part.isdigit() for part in args.class_expr.split(',')):
    indices = map(int, args.class_expr.split(','))
    class_expr = 'tuple(cols[i-1] for i in indices)'
  else:
    class_expr = args.class_expr
  class_expr = compile(class_expr, filename='class_expression', mode='eval')

  if args.keep_headers:
    headers = sys.stdin.readline()
   
  def class_func(line):
    cols = line.split('\t')
    return eval(class_expr, locals(), globals())

  # Sample the input
  random.seed(19071985)
  samples = defaultdict(lambda: ReservoirSample(args.n))  # class -> sample
  for line in sys.stdin:
    cls = class_func(line)
    samples[cls].add(line)

  # Write sample to output
  if args.keep_headers:
    sys.stdout.write(headers)
  for cls in sorted(samples.keys()):
    if samples[cls].seen < args.min_class_size:
      continue
    for line_no, line in sorted(samples[cls].result):
      sys.stdout.write(line)
