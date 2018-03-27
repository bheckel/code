#!/bin/sh

for fs in `df -k | awk '{print $1}' | sed -n "3,14 p"`; do
  x=`df -kl | grep $fs | awk '{ print $5 }'`
  y=90%

  if [ $x -gt $y ]; then
    message="File System `df -k |grep $fs |awk '{print $6\", \"$5}'` Full!!!"
    echo $message | mailx -s "`hostname` - File System Full Warning !!!"  wtf@pig.com
  fi
done
