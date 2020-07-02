#!/bin/bash

diskpct=$(df /cygdrive/p|tail -1|awk '{print $5}'|perl -pe 's/%//')

if [ $diskpct -gt 75 ];then 
  echo "may have full disk $diskpct";
  ###email.pl
  ###exit 1
fi

