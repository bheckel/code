#!/bin/sh
##############################################################################
#     Name: dfmon
#
#  Summary: Monitor disk space and sent email if hit threshold.
#
#  Adapted: Thu 24 May 2001 13:57:59 (Bob Heckel -- InformIT Unix Hints and
#                                     Hacks Kirk Waingrow)
##############################################################################

df -k | grep -iv filesystem | awk '{ print $6" "$5}' | while read LINE; do
 PERC=`echo $LINE | cut -d"%" -f1 | awk '{ print $2 }'`
 if [ $PERC -gt 33 ]; then
   ###echo "${PERC}% ALERT"  | Mail -s "${LINE} on `hostname` is almost full"  admin@rocket.ugu.com
   echo "ALMOST FULL ALERT $LINE" 
 fi
done
