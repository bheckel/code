#!/bin/sh

# Created: Mon Jun  9 09:54:06 2003 (Bob Heckel)
# Modified: Thu 26 Aug 2004 15:12:56 (Bob Heckel)

# Only keep the last version of the logs.  Assuming it will always be run via
# cron.  E.g.:
# 15 4 * * * find /opt/apache/logs/access_log -size +500000000c && /opt/bin/rotatelog -c 

BIN=/usr/sbin
LOG=/var/log/apache

if [ "$1" = '-c' ]; then
  mv -i $LOG/access_log $LOG/access_log.old
  mv -i $LOG/error_log $LOG/error_log.old
  $BIN/apachectl graceful
  # Must be a fairly long wait.
  sleep 600
  gzip $LOG/access_log.old $LOG/error_log.old
else
  echo "Error: $0 not intended for interactive use, try -c"
  echo
  echo "Usage: `basename $0` -c
  Rotates Apache Server access and error logs (under cron)"
  exit 1
fi

exit 0
