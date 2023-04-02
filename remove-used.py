#!/bin/env python3
from argparse import ArgumentParser
import sys
import re

def get_str_without_line_number(str):
    exp = re.compile(r"^(?P<filename>.+?):(?P<linenumber>.+?)\s(?P<desc>.+?)(\(see line .+\))?(on lines: .+?)?$")
    r = exp.match(str)
    if not r:
        return str
    r = r.groupdict()
    return r['filename'] + " " + r["desc"] + "\n"

def build_hash(list):
    s = set()
    for i in list:
        str = get_str_without_line_number(i)
        s.add(str)
    return s 
    

def main():
    parser = ArgumentParser(description="Remove used issue from smatch list, line number will be ignored.")
    parser.add_argument("file")
    parser.add_argument("--list",help="file name for issue used")
    args = parser.parse_args()
    output = sys.stdout
   
    list = []
    if args.list:
        with open(args.list) as f:
            list = f.readlines()

    hash = build_hash(list)

    with open(args.file) as f:
        while True:
            line = f.readline()
            if not line: break
            if not get_str_without_line_number(line) in hash:
                output.write(line)

main()
