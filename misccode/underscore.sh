#!/bin/sh
##############################################################################
#     Name: underscore.sh
#
#  Summary: Replace spaces with underscores for all files.
#
#           TODO add a -u to put spaces back
#
#  Adapted: Sun 10 Feb 2002 12:26:00 (Bob Heckel -- UGU Tip 02/10/02)
# Modified: Tue 14 Aug 2007 09:54:33 (Bob Heckel)
##############################################################################

Usage() {
  echo "Usage: `basename $0` myfilename
  e.g. `basename $0` *
  e.g. `basename $0` foo bar.xls
  e.g. `basename $0` eQuality*
  e.g. `basename $0` Utah\ Apply\ Rules\ *

  Replaces spaces in filename(s) with underscores
  Does NOT do directory names
  Does NOT recurse"
  exit 1
}

[ $# -lt 2 ] && Usage

i=0

for f in "$@"; do 
  if [ -f "$f" ]; then 
    mv "$f" `echo $f | sed 's/ /_/g'` >/dev/null 2>&1
    # Files not needing underscoring will be attempted as well, this
    # eliminates them from the count
    if [ $? -eq 0 ]; then
      (( i = i + 1 ))
    fi
  fi 
done

echo $i underscored
