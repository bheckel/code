#!/bin/sh
##############################################################################
#     Name: hiber.sh
#
#  Summary: W2K hibernation hack to accomodate Cygwin.
#
#  Created: Sun 12 Dec 2004 00:29:29 (Bob Heckel)
# Modified: Wed 13 Apr 2005 23:02:17 (Bob Heckel)
##############################################################################
  
echo 'hibernating...'
echo "...sync'ing..."
sync
sleep 5
echo ...shutting down cron...
cygrunsrv -Q cron
sleep 5
cygrunsrv -E cron
sleep 5
cygrunsrv -Q cron
# Want to go slow enough to let tcpip connections drop, etc.
shutdown -h 120
echo ...returning from hibernation...
sleep 20
echo restarting Services...
sleep 5
cygrunsrv -S cron
sleep 5
cygrunsrv -Q cron
echo ...done...have a better one.
