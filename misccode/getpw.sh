#!/bin/sh

if [ -e $HOME/bin/pword ]; then
  # Poor man's .rhosts using ROT13
  cat $HOME/bin/pword | tr 'a-zA-Z' 'n-za-mN-ZA-M'
  exit 0
else
  echo pword file missing
  exit 1
fi
