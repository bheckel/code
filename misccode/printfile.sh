#!/bin/sh

# Created: Mon Apr 14 09:38:45 2003 (Bob Heckel)
# Modified: Wed 20 Oct 2004 14:19:58 (Bob Heckel)

N_MIN_ARGS=1
N_MAX_ARGS=2

Usage() {
  echo "Usage: `basename $0` [-l] TEXTFILE_TO_PRINT
               -l  use preconfigured 180 char wide 1up Landscape setting

  E.g. `basename $0` foo.txt
  E.g. :!printfile %    <---from within Vim

  Print a file using the Win32 Print File utility (should be aliased to 
  prfile)"

  exit 1
}

if [ "$#" -gt $N_MAX_ARGS -o "$#" -lt $N_MIN_ARGS ]; then
  Usage
fi

if [ $1 = '-l' ]; then
  WINP=$(cygpath -w $2)
  c:/"Program Files"/PrintFile/PRFILE32.EXE /n:Landscape "$WINP"
else
  WINP=$(cygpath -w $1)
  c:/"Program Files"/PrintFile/PRFILE32.EXE "$WINP"
fi
