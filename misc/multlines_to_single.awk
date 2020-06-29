#!/bin/sh
##############################################################################
# Using original files with multiple lines per record, parse to a single line.
#
# TODO this is crap
# 
# Created: Fri, 05 Nov 1999 13:39:28 (Bob Heckel)
##############################################################################

awk 'BEGIN {RS=""}
      {if ($1 ne "") 
        print $1,$2,$3,$4,$5,$6,$7,$8,$9
      }' $1


