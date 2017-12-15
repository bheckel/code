#!/bin/sh
##############################################################################
#     Name: cmdline_args.sh
#
#  Summary: Demo of defaults and required numeric input from command line.
#
#  Adapted: Wed 05 Sep 2001 09:57:06 (Bob #  Heckel--
#                       http://www.linuxdoc.org/LDP/abs/html/sha-bang.html )
##############################################################################

case "$1" in
  ""      ) num=42;;
  *[!0-9]*) echo "Usage: `basename $0` dragons-to-slay"; exit 1;;
  *       ) num=$1;;
esac

echo $num dragons queued
