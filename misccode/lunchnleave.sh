#!/bin/bash

if [ `date +%u` -ne 7 -a `date +%u` -ne 6 ];then  # weekday
  if [ `date +%H` -eq 12 -a `date +%m` -lt 30 -o `date +%H` -eq 16 -a `date +%m` -gt 15 ];then
    echo '!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!'
  fi
fi
