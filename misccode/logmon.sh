#!/bin/sh
##############################################################################
#     Name: logmon
#
#  Summary: Monitor error logs for specific changes.
#
#  Adapted: Thu 24 May 2001 13:57:59 (Bob Heckel -- InformIT Unix Hints and
#                                     Hacks Kirk Waingrow)
##############################################################################

touch /tmp/sys.old

if [ "$@" ]; then
  LOGFILE=$1
else
  LOGFILE='/apache/logs/error_log'
fi

if [ ! -e $LOGFILE ]; then
  echo "Logfile: $LOGFILE does not exist.  Exiting."
  exit 1
fi

while [ 1 ]; do
 grep '[error]' $LOGFILE > /tmp/sys.new
 FOUND=`diff /tmp/sys.new /tmp/sys.old`
 if [ -n "$FOUND" ]; then
   ###mail -s "ALERT ERROR" admin@rocket.ugu.com < /tmp/sys.new
   echo "ALERT ERROR"
   mv /tmp/sys.new /tmp/sys.old
 else
   sleep 10
 fi
done
