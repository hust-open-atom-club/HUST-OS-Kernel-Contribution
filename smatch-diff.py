#!/bin/env python3

import difflib
import re
from sys import argv
from pprint import pprint
from argparse import ArgumentParser
import sys

# Get real diff, ignore number line
def get_real_diff(seq1:list,seq2:list):
    exp = re.compile(r"^(?P<filename>.+?):(?P<linenumber>.+?)\s(?P<desc>.+?)(\(see line .+\))?$")
    # pprint(seq1)
    # pprint(seq2)
    seq1_only = []
    seq2_only = []
    def is_same(str1:str, str2:str):
        if str1==str2:
            return True
        r1 = exp.match(str1)
        r2 = exp.match(str2)
        if not (r1 and r2):
            return True

        r1 = r1.groupdict()
        r2 = r2.groupdict()
        if r1['filename'] == r2['filename']:
            if r1['desc'] == r2['desc']:
                return True

        return False

    len1 = len(seq1)
    len2 = len(seq2)
    d = [[0 for x in range(len2+1)] for y in range(len1+1)]

    # dp, core algorithm
    for i in range(1,len1+1):
        for j in range(1,len2+1):
            # pprint(d)
            # pprint(i); pprint(j)
            if is_same(seq1[i-1],seq2[j-1]):
                d[i][j] = d[i-1][j-1] + 1
            else:
                d[i][j] = max(d[i][j-1],d[i-1][j])

    # pprint(d)


    for i in range(1,len1+1):
        if d[i][len2]==d[i-1][len2]:
            seq1_only.append(seq1[i-1]);
    for i in range(1,len2+1):
        if d[len1][i]==d[len1][i-1]:
            seq2_only.append(seq2[i-1]);

    return (seq1_only,seq2_only)

def submit(seq1,seq2,filea=sys.stdout,fileb=sys.stdout):
    (s1,s2) = get_real_diff(seq1,seq2)
    same_file = (filea == fileb)
    for i in s1:
        filea.write(("-" if same_file else "") + i)
    for i in s2:
        fileb.write(("+" if same_file else "") + i)

            
        

def diff(filea,fileb):
    with open(filea) as fa, open(fileb) as fb:
        lines_a = fa.readlines()
        lines_b = fb.readlines()
        return difflib.unified_diff(lines_a,lines_b)


def main():
    parser = ArgumentParser(description="diff output from smatch, ignore line number.")
    parser.add_argument("file1")
    parser.add_argument("file2")
    parser.add_argument("-o1",metavar="output1",help="output for unique line in file1, stdout as default.",required=False)
    parser.add_argument("-o2",metavar="output2",help="output for unique line in file2, stdout as default.",required=False)
    args = parser.parse_args()

    filea = args.file1
    fileb = args.file2

    ofilea = open(args.o1,"w") if args.o1 else sys.stdout
    ofileb = open(args.o2,"w") if args.o2 else sys.stdout

    diff_result = diff(filea,fileb)
    
    def push_to_list(str,list:list):
        if str[1:].startswith("  "):
            return
        list.append(str[1:])

    lines_a = []
    lines_b = []
    for line in diff_result:
        if line.startswith("-"):
            push_to_list(line,lines_a)
        elif line.startswith("+"):
            push_to_list(line,lines_b)
        else:
            if len(lines_a) != 0 or len(lines_b) != 0:
                submit(lines_a,lines_b,ofilea,ofileb)
            lines_a.clear()
            lines_b.clear()

main()

