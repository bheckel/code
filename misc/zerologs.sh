#!/bin/sh
##############################################################################
#     Name: zerologs
#
#  Summary: Zero out all files in a directory with a specific extension.
#
#           TODO how to zero a file called log?
#
#  Adapted: Fri 01 Feb 2002 17:38:03 (Bob Heckel -- UGU Tips 02/01/02)
# Modified: Sat 01 Feb 2003 15:34:55 (Bob Heckel)
##############################################################################


Usage() {
  echo "Usage: `basename $0` EXTENSION
  E.g. `basename $0` log
  Zeroes out all files in \$PWD with a particular extension."
  exit 1
}

N_EXPECTED_ARGS=1

if [ "$#" -ne $N_EXPECTED_ARGS ]; then
  Usage
fi

echo -n "Zero out all $1 files in $PWD? [y/n] "

read yesno

if [ $yesno = y ]; then
  for f in *.$1; do
    > $f 
    # TODO use a -v verbose switch to get this
    ###echo "$f has been zeroed."
  done
else
  echo 'Aborted by user.  No changes made.'
  exit 1
fi
