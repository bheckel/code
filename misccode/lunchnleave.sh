#!/bin/bash

if [ `date +%u` -ne 0 -a `date +%u` -ne 6 ];then
  if [ `date +%H` -eq 12 -o `date +%H` -gt 15 ];then
    echo '!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!'
  fi
fi
