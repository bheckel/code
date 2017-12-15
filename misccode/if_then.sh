#!/bin/sh

if [ $# -eq 0 ]; then
  echo "No arguments supplied"
fi


# Less reliable if $1 has been initialized but is empty
[ -z "$1" ] && echo "No argument supplied"


f=_profile
if [ $f = '_profile' ]; then
  echo 'yes'
  echo 'two lines ok without a do end etc'
else
  echo 'no'
fi


[[ $x -lt 0 ]] && echo "${fg_redbold}SERIOUS FAILURE ${normal}" && exit 1
