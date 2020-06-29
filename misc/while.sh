#!/bin/sh

x=0

while (( x < 5 )); do
  echo $x
  let "x = x+1"
done
