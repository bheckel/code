#!/bin/sh

if [ "$1" = "" ];then
  cygstart /cygdrive/u/chats
else
  vi /cygdrive/u/chats/$1.`date +%d%b%y`.txt
fi
