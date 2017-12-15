#!/bin/sh

if [ ! "$1" ]; then
  echo 'Usage: rgrep findthisstr [lookhere/]'
  echo "(this function is deprecated.  $ grep -r findthis lookhere/"
  echo "or $ ~/bin/bgrep -r findthisstr  may be a better choice)"
else
  find "./$2" -type f -exec grep "$1" {} /dev/null \;
fi
