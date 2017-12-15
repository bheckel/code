#!/bin/sh
##############################################################################
#     Name: tmpclean.parsifal.sh
#
#  Summary: Disk space reclaimer.  Usually runs via cron after being symlinked
#           to ~/bin/tmpclean
#
#           TODO allow dirs in addition to the default tmp to be passed as
#           parms e.g. /home/bheckel/pilotpgms/rescobkup/
#
#  Created: Sat 11 Dec 2004 19:08:50 (Bob Heckel)
# Modified: Sun 15 Jul 2007 10:07:33 (Bob Heckel)
##############################################################################
  
# Best to use find's -print0 with xarg's --null
/bin/find /home/bheckel/tmp -type f -mtime +360 -print0 | xargs --null rm -f 
/bin/find /home/bheckel/tmp -type d -mtime +360 -print0 | xargs --null rmdir
