#!/bin/sh

# Run this script as chemlms:
# $ nohup eom_arch.sh&

while [ 1 ];
  do if [ `date +%d` -eq 30 -a `date +%H` -eq 23 -a `date +%M` -eq 58 ]; then 
    echo "archive_files.sh and Compress_Tars.sh running via $0" | mailx -s 'rtpsh005 ~chemlms/eom_arch.sh' rsh86800@sgk.com
    /home/chemlms/Scripts/archive_files.sh && 
    /home/chemlms/Scripts/Compress_Tars.sh
    echo ok $0
    exit
  fi
  sleep 59
done 

exit
