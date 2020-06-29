#!/bin/bash
##############################################################################
#     Name: arithmetic.sh
#
#  Summary: Demo of arithmetic and calculating dates before
#
#           Requires bash at least
#
#           Sample call:
#
#           $ for i in -9 -8 -7 0 3 4 5; do ./arithmetic.sh 200508 $i; done
#
#  Adapted: Sat 10 Sep 2005 11:13:51 (Bob Heckel -- unixreview.com)
##############################################################################
  
typeset ym=$1 pn=$2

(( m = ym % 100 ))
(( y = ym / 100 ))

while (( pn != 0 )); do
  if (( pn > 0 )); then
    if (( m == 12 ))
    then (( m = 1 )); (( y = y + 1 ))
    else (( m = m + 1 ))
    fi
    (( pn = pn - 1 ))
  else
    if (( m == 1 ))
    then (( m = 12 )); (( y = y - 1 ))
    else (( m = m - 1 ))
    fi
    (( pn = pn + 1 ))
  fi
done

printf "%s\n" $(( 100*y + m ))
