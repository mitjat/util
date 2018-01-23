#!/usr/bin/python

import sys


def parse(path):
  ret = {}
  for line in open(path):
    if line.startswith('Counters:'):
      continue
    if not line.strip():
      continue
    num, name = line.strip().split(' ', 1)
    if name.startswith('passage-'):
      name = name[len('passage-'):]
    ret[name] = int(num)
  return ret


path1, path2 = sys.argv[1:]
d1, d2 = parse(path1), parse(path2)

print '%11s  %11s  %11s  %s' % (path1, path2, 'diff', 'counter')
for name in sorted(set(d1.keys() + d2.keys())):
  if name.startswith('mr-'):
    continue
  if d1.get(name, 0) == 0 and d2.get(name, 0) == 0:
    continue
  diff = '--' if not (name in d1 and name in d2) else (
      '%+d' % (d2[name] - d1[name])) if (d2[name] != d1[name]) else ''
  diffperc = diff if diff in ('--', '') or d1.get(
      name, 0) == 0 else '%.1f%%' % (int(diff) * 100.0 / d1[name])
  print '%13s  %13s  %13s  %6s     %s' % (d1.get(name, '--'),
                                          d2.get(name, '--'), diff, diffperc,
                                          name)
