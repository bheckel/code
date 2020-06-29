#!/bin/sh
##############################################################################
#     Name: newname
#
#  Summary: Interactively rename files.
#
#  Adapted: Tue 25 Feb 2003 11:00:07 (Bob Heckel -- Unix Power Tools Ch 18.13)
##############################################################################
  
Usage() {
  echo "Usage: `basename $0` filepattern1...
  E.g. `basename $0` *.txt
Allows interactive renaming of files in a directory.
Press enter when prompted to skip the rename."
  exit 1
}

N_MIN_ARGS=1

if [ "$#" -lt $N_MIN_ARGS ]; then 
  Usage
fi

# For each filename passed in.
for f; do
  echo -n "old name is $f, new name is [enter to skip]: "
  read newname
  mv "$f" "$newname"
done
