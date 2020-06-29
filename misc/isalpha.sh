#!/bin/bash
##############################################################################
#     Name: isalpha.sh
#
#  Summary: Test for alphabetics.
#
#  Adapted: Tue 11 Sep 2001 15:52:50 (Bob Heckel--
#                     http://www.linuxdoc.org/LDP/abs/html/testbranch.html)
##############################################################################

# Functions must precede calls.

# Tests whether *first character* of input string is alphabetic.
isalpha() {
  # Check for argument passed.
  if [ -z "$1" ]; then
    echo 'Pass character to determine if alphabetical or numeric'
    return 1
  fi

  case "$1" in
    [a-zA-Z]* ) return 0;;
            * ) return 1;;
  esac
}             

isalpha "b"
