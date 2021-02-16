#!/usr/bin/env python
import os
import sys
import argparse

sys.stdout.reconfigure(line_buffering=True)

p = argparse.ArgumentParser()
p.add_argument('-d', '--directory', default='.')
args = p.parse_args()

pre_table = ''
lines = []


def write_to_file():
    if pre_table == '':
        return
    target_path = '{}/{}.ddl'.format(args.directory, pre_table)
    os.makedirs(os.path.dirname(target_path), exist_ok=True)
    with open(target_path, 'w') as f:
        f.writelines([l + '\n' for l in lines])
    print(target_path, file=sys.stderr)


def one_line(line):
    global pre_table
    global lines
    if '\t--DROP VIEW ' in line:
        write_to_file()
        pre_table = '/'.join(line.split('\t')[:2])
        lines = []
        lines.append(line.split('\t')[2])
    else:
        lines.append(line)

try:
    line = sys.stdin.readline()
    while line:
        line = line.strip("\n")
        line = one_line(line)
        line = sys.stdin.readline()
    write_to_file()
except BrokenPipeError:
    devnull = os.open(os.devnull, os.O_WRONLY)
    os.dup2(devnull, sys.stdout.fileno())
    sys.exit(1)
