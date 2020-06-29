#! /bin/sh

# range - Generate range of numbers.
#
# DEPRECATED, just use  $ seq 3 5  but this is a good e.g. of WHILE
#
# Adapted: Sat 13 Oct 2001 22:39:37 (Bob Heckel -- UGU tip)
# Modified: Thu 18 Mar 2004 14:22:49 (Bob Heckel)

lo=$1
hi=$2

while [ $lo -le $hi ]
do
  echo -n $lo " "
  lo=`expr $lo + 1`
done

