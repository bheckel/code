#!/bin/sh

parse_arguments() {
  # Parse command line arguments
  while [ "$1" != "" ] ; do
     case $1 in
        -quiet)
           headless=1
           shift
           continue;;
        -help)
           headless=2
           shift
           continue;;
        *)
           shift
           continue;;
     esac
  done
}
parse_arguments $@
echo $headless
