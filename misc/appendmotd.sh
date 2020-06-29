#!/bin/sh

# Append most recent backup information into message-of-the-day
#
# Assumes the 'u' option was passed to ufsdump 
#
# e.g. 59 03 * * 0 /usr/sbin/ufsdump 0uf /dev/rmt/0ubn /home

# Modified: Mon 04 Apr 2005 14:41:25 (Bob Heckel)

# Remove old dump dates (if any), leave everything else
/bin/cat /etc/motd | /usr/bin/grep -v "^Last" > /tmp/motd.$$

# Partition being backed up (aka /home)
PART=c1t1d0s0

# Get dates for last level 0 and 5 backups (e.g. Fri Aug 27 13:43:37)
FULL=`/usr/bin/grep "/dev/rdsk/c1t1d0s0               0" /etc/dumpdates | awk '{print $3,$4,$5,$6}'`
###INCR3=`/usr/bin/grep "/dev/rdsk/c1t1d0s0               3" /etc/dumpdates | awk '{print $3,$4,$5,$6}'`
INCR1=`/usr/bin/grep "/dev/rdsk/c1t1d0s0               1" /etc/dumpdates | awk '{print $3,$4,$5,$6}'`
INCR2=`/usr/bin/grep "/dev/rdsk/c1t1d0s0               2" /etc/dumpdates | awk '{print $3,$4,$5,$6}'`
INCR3=`/usr/bin/grep "/dev/rdsk/c1t1d0s0               3" /etc/dumpdates | awk '{print $3,$4,$5,$6}'`
INCR4=`/usr/bin/grep "/dev/rdsk/c1t1d0s0               4" /etc/dumpdates | awk '{print $3,$4,$5,$6}'`
INCR5=`/usr/bin/grep "/dev/rdsk/c1t1d0s0               5" /etc/dumpdates | awk '{print $3,$4,$5,$6}'`

echo "Last full backup of $PART:                  " $FULL >> /tmp/motd.$$
echo "Last incremental level 1 backup of $PART:   " $INCR1 >> /tmp/motd.$$
echo "Last incremental level 2 backup of $PART:   " $INCR2 >> /tmp/motd.$$
echo "Last incremental level 3 backup of $PART:   " $INCR3 >> /tmp/motd.$$
echo "Last incremental level 4 backup of $PART:   " $INCR4 >> /tmp/motd.$$
echo "Last incremental level 5 backup of $PART:   " $INCR5 >> /tmp/motd.$$

mv /tmp/motd.$$ /etc/motd
