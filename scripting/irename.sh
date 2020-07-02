#!/bin/bash

# Prerequisite:
# $ mkdir -p ~/perllib/File
# $ cp ~/code/perl/Irenamer.pm ~/perllib/File/

while getopts qrh the_opt; do
  case "$the_opt" in
     q  )  perl -MFile::Irenamer -e "InteractiveRename()" && exit ;;
     r  )  perl -MFile::Irenamer -e "InteractiveRename(verbose,recurse)" && exit ;;
     *  )  echo >&2 \
              "Usage: $0 [-vr] 
               -q quiet
               -r recurse"
              exit 1
              ;;
  esac
done

# Fall-thru
perl -MFile::Irenamer -e "InteractiveRename(verbose)" 
