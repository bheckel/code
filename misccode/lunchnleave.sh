#!/bin/bash

if [ `date +%u` -ne 7 -a `date +%u` -ne 6 ];then  # weekday
  if [ `date +%H` -eq 12 -o `date +%H` -gt 15 ];then
    echo '!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!'
  fi
fi
