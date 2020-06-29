#!/bin/bash

[ $# -lt 1 ] && echo "Usage: $0 /Drugs/TMMEligibility/UWP/Imports/20170320/Output/UWPTMM_candidates_fdw.csv" && exit 1

echo "import $1 ?"
read
echo importing...

chmod 777 $1
cp -p $1 /mnt/nfs/home/janitor/dataproc/tmm/pending
sleep 3
ls -l /mnt/nfs/home/janitor/dataproc/tmm/pending/
watch -d 'ls -l /mnt/nfs/home/janitor/dataproc/tmm/pending/'

