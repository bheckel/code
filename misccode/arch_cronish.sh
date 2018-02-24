#!/bin/sh

# 2009-07-16 obsolete - see eom_arch.sh

# As chemlms

while [ 1 ];
  do if [ `date +%H` -eq 23 -a `date +%M` -eq 58 ]; then 
    echo 'archive_files.sh and Compress_Tars.sh running' | mailx -s 'arch_cronish on rtpsh005' rsh86800@sgk.com
    /home/chemlms/Scripts/archive_files.sh && 
    /home/chemlms/Scripts/Compress_Tars.sh
    echo ok
    exit;
  fi;
  sleep 30;
done; 

exit
