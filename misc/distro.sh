#!/bin/bash

if [ -x /usr/bin/lsb_release ];then
  lsb_release -a
else
  cat /etc/*-release | grep VERSION | perl -pe 's/VERSION="//g'
fi
