#!/bin/sh
##############################################################################
#     Name: read_file_nonblanklines.sh
#
#  Summary: Demo of how to read a few lines from a file 
#
#  Created: Thu 26 Apr 2007 16:05:30 (Bob Heckel)
##############################################################################

FILE=$HOME/bladerun_crawl

cat $FILE | 
  while read LINE
    do
      SLICE="`echo $LINE | awk '{print $1}'`"
      if test $SLICE; then
        echo "ok line is not blank: $SLICE"
      fi
    done
