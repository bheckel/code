#!/bin/sh
##############################################################################
#    Name: sumlist.awk
# Summary: Sum 1st col of txt file except for header line (row).
#          Fast alternative to pasting into Excel.
#
# Created: Sat, 18 Sep 1999 20:22:44 (Bob Heckel)
##############################################################################

awk 'BEGIN { print "Summing column 1:" }
{ sum += $1 }
END { print sum }' $1
