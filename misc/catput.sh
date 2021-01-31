#!/bin/bash
##############################################################################
#     Name: catput.sh (s/b symlinked as ~/bin/catput)
#
#  Summary: Quickly force a small file to the clipboard
#
#  Created: Thu 25-Aug 2005 (Bob Heckel)
# Modified: Tue 05-Jan-2021 (Bob Heckel)
##############################################################################
  
Usage() {
  echo "Usage: `basename $0` FILE
  E.g. `basename $0` clipboardme.txt
  Sends a file to the clipboard"
  exit 1
}

N_EXPECTED_ARGS=1

if [ "$#" -ne $N_EXPECTED_ARGS ]; then 
  Usage
fi

if [ -e "$1" ]; then
  filesize=$(find "$1" -printf "%s" )
else
  echo File $1 does not exist in this dir.  Exiting.
  exit 1
fi

# Don't overload RAM
if [ $filesize -lt 5000000 ]; then
  if [ ${OSTYPE:0:6} = 'cygwin' ]; then
    if [ -e /usr/bin/putclip ]; then
      echo 'putclip...'
      cat "$1" | putclip
    else
      echo putclip not installed
    fi
  else
    echo 'xclip...'
    cat "$1" | xclip
  fi
else
  echo Failed: file too large: $filesize bytes
  echo Must be smaller than 5MB.  Exiting.
  exit 1
fi
