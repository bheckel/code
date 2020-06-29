#!/bin/sh

# Arithmetic evaluation

x=6
y=3

let "z = x+y+1"

echo $z
echo $?  # no error, returns 0

let "z > 100"
echo $?  # not true, returns 1

echo

# Same.  This is the style needed for if (( ... ));then ... fi
(( z = x+y+1 ))

echo $z
echo $?  # no error, returns 0

let "z > 100"
echo $?  # not true, returns 1
