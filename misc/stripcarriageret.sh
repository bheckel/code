#!/bin/sh

# From tidy.exe website.
# Also see d2u, u2d, dos2unix, etc.
# Adapted: Tue, 04 Jan 2000 15:45:59 (Bob Heckel)
# Modified: Tue, 05 Dec 2000 13:47:32 (Bob Heckel)

echo Stripping carriage returns...

for i; do
  # If a writable file.
  if [ -f $i ]; then
    if [ -w $i ]; then
      # Strip CRs from input and output to temp file.
      tr -d '\015' < $i > tounix.tmp
      mv tounix.tmp $i
    else
      echo $i: write-protected
    fi
  else
    echo $i: not a file
  fi
done

echo ...carriage returns stripped successfully.
