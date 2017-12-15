#!/bin/bash
##############################################################################
#     Name: arguments_parameters.sh
#
#  Summary: Demo of differences between parameter arguments $* and $@
#
#           Invoke this script with several arguments, such as "one two
#           three".
#
#  Adapted: Fri 07 Sep 2001 15:55:11 (Bob Heckel--
#                http://www.linuxdoc.org/LDP/abs/html/internalvariables.html)
##############################################################################

if [ ! -n "$1" ]; then
  echo "Usage: `basename $0` argument1 argument2 etc."
  exit 1
fi  

index=1

echo "Listing args with \"\$*\":"
for arg in "$*"  # Doesn't work properly if "$*" isn't quoted.
  do
    echo "Arg #$index = $arg"
    let "index+=1"
  done
echo "Entire arg list seen as single word."
echo

index=1

echo "Listing args with \"\$@\":"
for arg in "$@"
  do
    echo "Arg #$index = $arg"
    let "index+=1"
  done
echo "Arg list seen as separate words."

exit 0
