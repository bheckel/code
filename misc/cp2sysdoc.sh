#!/bin/sh
  
Usage() {
  echo "Usage: `basename $0` FOO
       Copy (overwrite) my version of file FOO to the LMITH Sysdoc dir
       Handles spaces in filenames if backslashed:
       e.g. cp2sysdoc.sh SAS\ IntrNet\ Query\ System.doc" 
  exit 1
}

N_EXPECTED_ARGS=1

if [ "$#" -ne $N_EXPECTED_ARGS ]; then 
  Usage
fi

cp -v "$1" "K:/ORKAND/System Documentation/"
