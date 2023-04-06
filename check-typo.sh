#!/bin/env bash
set -e

JOBS=1
SCRIPT_NAME=$0

while getopts "j:h" arg
do
  case $arg in
    j)
      JOBS=$OPTARG
      ;;
    h)
      echo "$SCRIPT_NAME - Check typo problems in linux"
      echo "Usage: $SCRIPT_NAME [-h] [-j{JOBS, default 1}] DIR"
      echo
      echo "DIR should contains linux subdir."
      echo "WARN: Concurrency may lead to unordered result, which is hard to diff."
      exit 0
      ;;
  esac
done

shift $((OPTIND - 1))

DIR=$1
if [[ -z $DIR ]]
then
  >&2 echo "No directory selected. Try ${SCRIPT_NAME} -h for help."
  exit 1
fi

# Use fifo for job control.
tmp_fifofile="/tmp/$$.fifo"
mkfifo $tmp_fifofile   
exec 6<>$tmp_fifofile  
rm $tmp_fifofile  

thread_num=JOBS  

for ((i=0;i<${thread_num};i++));do
    echo
done >&6

pushd $DIR/linux >&-
files=$(find . -name "*.c")
count=`echo $files | wc -w`
>&2 echo "Processing ${count} files."
num=0
for i in $files
do
  read -u6
  num=$[$num+1]
  >&2 echo "[${num}/${count}] Checking ${i}..."
  {
    ./scripts/checkpatch.pl -f ${i} --show-types --no-summary --terse || :
    echo >&6
  } &
done

popd >&-
wait 

exec 6>&- 

