#!/bin/bash

#TTY=$(ps -ef | awk '{print $6}' | uniq | grep pts/2)
# Cygwin
TTY=$(ps -ef | awk '{print $4}' | uniq | grep pty2)

if [ ! "${TTY}" ];then
  echo "${TTY} running tos"
  tos
fi
