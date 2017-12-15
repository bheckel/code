#!/bin/bash

SASUSERS="bob.heckel@taeb.com"

runcmd(){
  cat <<HERE
Hi,

Please check the following list for any 45+ day old sessions belonging to you.
Unless you have kept an EGP session open for a very long time these are
probably the result of an old job failure.

They will be deleted in the next several days to save diskspace.  If that’s ok,
no reply is required.

Thanks!

HERE

  sudo find /saswork -type d -mtime +45 | sudo xargs ls -ldh | awk '{print $3,$6,$7,$8,$9}' | grep -v '^sas' | uniq | sort
}

runcmd
###runcmd | mail -s "[cron] SAS workspace cleanup" $SASUSERS

