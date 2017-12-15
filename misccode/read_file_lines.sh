#!/bin/sh
##############################################################################
#     Name: read_file_lines.sh
#
#  Summary: Demo of how to read a few lines from a file or read a file
#           while doing conditional things on each line.
#
#  Adapted: Wed 05 Sep 2001 16:38:49 (Bob Heckel--
#                     http://www.linuxdoc.org/LDP/abs/html/special-chars.html)
# Modified: Mon 20 Jun 2016 15:59:17 (Bob Heckel)
##############################################################################

FILE=$HOME/junk

while read f; do
  if [ ! -z $f ]; then
    echo $f;
    echo "more with same line $f";
  fi
done <$FILE

###{
###read LINE1
###read LINE2
###} < $FILE
###
###echo "First line in $FILE is:"
###echo "$LINE1"
###echo
###echo "Second line in $FILE is:"
###echo "$LINE2"
###echo 
###
###echo "!!!!!! now read and iterate the whole file to first blank line !!!!!!"
###cat $FILE | 
###  while read LINE
###    do
###      SLICE="`echo $LINE | awk '{print $1}'`"
###      if test $SLICE; then
###        echo "ok line is not blank: $SLICE"
###      fi
###    done
