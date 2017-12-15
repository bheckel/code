#! /bin/sh

LO=$1;HI=$2

while [ $LO -le $HI ]; do
  echo -n $LO " "
  LO=`expr $LO + 1`
done
