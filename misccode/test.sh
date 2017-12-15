#!/bin/sh
##############################################################################
#     Name: test.sh
#
#  Summary: Comparison of numeric and string truth.
#
#  Created: Thu 13 Aug 2009 15:26:59 (Bob Heckel)
##############################################################################
  
X=1
Y=01

if test "$X" -eq "$Y"; then
  echo yes  # <---
else
  echo no
fi

# Same
if [ "$X" -eq "$Y" ]; then
  echo yes  # <---
else
  echo no
fi


if [ "$X" = "$Y" ]; then
  echo yes
else
  echo no  # <---
fi
