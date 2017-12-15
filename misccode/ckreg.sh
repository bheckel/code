#!/bin/sh
##############################################################################
#     Name: ckreg.sh
#
#  Summary: Check Register webpage for data.
#
#  Created: Fri 25 Feb 2005 11:05:54 (Bob Heckel)
##############################################################################
  
if [ "$#" -lt 3 ]; then 
  echo 'usage: ckreg evt yyyy STATE'
  exit 1
fi

# ckreg nat 2004 TEX && lb tx 04 nat |tail -1
w3m -dump http://158.111.2.21/sasweb/nchs/daeb/${1}${2}.html | grep $3
