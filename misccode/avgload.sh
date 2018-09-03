#!/bin/bash

# Modified: Sun 20 May 2018 12:30:26 (Bob Heckel)

# Usually for tmux

MYUP=`uptime`
LOAD="${MYUP##*average:}"

if [[ $HOSTNAME == 'sas-01' ]]; then
  MYDRV=`df -h /saswork|grep saswork | awk '{print $4}'`
  MYDRV2=`df -h /sasdata|grep sasdata | awk '{print $4}'`
elif [[ $HOSTNAME == 'appa' ]]; then
  MYDRV=`df -h |grep sda | awk '{print $5}'`
fi

echo -n $LOAD $MYDRV $MYDRV2
echo -n ' '
