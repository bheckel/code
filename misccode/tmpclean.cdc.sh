#!/bin/sh
##############################################################################
#     Name: tmpclean.cdc.sh
#
#  Summary: Disk space reclaimer.  Usually runs via cron after being symlinked
#           to ~/bin/tmpclean
#
#  Created: Sat 11 Dec 2004 19:08:50 (Bob Heckel)
# Modified: Thu 07 Apr 2005 10:27:42 (Bob Heckel)
##############################################################################
  
# Best to use find's -print0 with xarg's --null
/bin/find /home/bqh0/tmp -mtime +89 -print0 | xargs --null rm -f  2>/dev/null
# Will often find nothing.
/bin/find /home/bqh0/tmp -mtime +89 -print0 | xargs --null rmdir  2>/dev/null
