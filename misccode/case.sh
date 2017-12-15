#!/bin/sh

# See ~/bin/back for good example.

case `uname` in
  CYGWIN*)
    echo Yes we are running Cygwin
    ;;
  'foo bar' | foobar)
    echo Yes we are running foobar
    ;;
  *) 
    echo Sorry, only works under Cygwin or foobar.  Exiting.
    exit 1
    ;;
esac


# TODO why doesn't this work?
num=2
rng=`seq -s ' | ' 1 23`
echo $rng
case $num in
  `seq -s ' | ' 1 3` )
  ###1 | 2 | 3 )
    echo num
    ;;
  *)
    echo other
    ;;
esac
