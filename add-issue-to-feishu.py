#!/bin/env python3
import requests,json,re,getpass,sys,time
from argparse import ArgumentParser

appid = ""
tableid = ""
fname = ""
session_key = ""
url = ""
lines_processed = 0


def send_lines(lines):
    global session_key, lines_processed
    if not len(lines):
        return 

    data = [ { "fields": { "Bug Information":info } } for info in lines ]
    payload = json.dumps({
        "records": data
    })

    while not session_key:
        session_key = getpass.getpass("Your user access token: ")

    headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer %s' % session_key
    }

    response = requests.request("POST", url, headers=headers, data=payload)
    if response.status_code >= 200 and response.status_code < 300 and response.json()['code'] == 0:
        lines_processed = lines_processed + len(lines)
        print("%d lines processed." % lines_processed , end="\r")
    else:
        print("[ERR] failed at the line below. \n> %s" % lines[0],end="",file=sys.stderr)
        print("[ERR INFO] %s" % response.text,file=sys.stderr)
        exit(3)

def process(file):
    lines = []
    while True:
        line = file.readline()
        if not line:
            send_lines(lines)
            lines.clear()
            break
        lines.append(line)
        if len(lines) == 100:
            send_lines(lines)
            lines.clear()

def parse_args():
    global appid, tableid, fname, session_key, url
    parser = ArgumentParser(description="Upload issues to feishu bitable.")
    parser.add_argument("--url",help="url copied from browser.",required=True)
    parser.add_argument("--auth",help="user auth token, usually not required when file specified, \
                        could be get from https://open.feishu.cn/api-explorer/")
    parser.add_argument("file",help="file to process, if not specified, use stdin.",nargs='?')
    args = parser.parse_args()
    ddurl = args.url
    session_key = args.auth
    matches = re.match(r"^.+\/base\/(.+?)\?table=(.+?)&.*$",ddurl)
    if matches: 
        (appid,tableid) = matches.groups()
    else: pass
    fname = args.file


    if appid and tableid: 
        url = "https://open.feishu.cn/open-apis/bitable/v1/apps/%s/tables/%s/records/batch_create" % (appid,tableid)
    else:
        print("[ERR] argument error",file=sys.stderr)
        exit(1)
    
    

parse_args()
file = sys.stdin
if not fname and not session_key:
    print("Token key must be specified when using stdin as input file.")
    exit(1)
if fname:
    file = open(fname)

process(file)

