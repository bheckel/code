#!/bin/ksh
#
# Solaris Monitor Servers Script
# Purpose: Monitors servers via use of the ping command
# and notifies via email.
# Usage: Execute from crontab every 15 minutes.
# Dependencies: $ADMINDIR/mon_srv.dat
# Outputs: E-mail
#
# Submitter Email: gideon@infostruct.net
# Adapted: Bob Heckel
#***************************************************

# The directory the datfile resides in
ADMINDIR=/home/bheckel/bin
MAILADD=bheckel@cdc.gov,bheckel@sdf.lonestar.org

while read -r IP SRVNM
  do
    if test `/usr/sbin/ping $IP | grep -c "is alive"` -eq 0; then
      # Wait 5 minutes before checking again
      sleep 300
      if test `/usr/sbin/ping $IP | grep -c "is alive"` -eq 0; then
        mail $MAILADD <<EOF
From: $0
To: $MAILADD
Subject: $SRVNM is down as of `date`

$SRVNM is not responding.

this script run via cron on rdrtp

EOF
      fi
    fi
done < $ADMINDIR/mon_srv.dat
exit 0
