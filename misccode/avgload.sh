#!/bin/bash

MYUP=`uptime`
LOAD="${MYUP##*average:}"
MYDRV=`df -h /saswork|grep saswork | awk '{print $4}'`
MYDRV2=`df -h /sasdata|grep sasdata | awk '{print $4}'`
echo -n $LOAD $MYDRV $MYDRV2
echo -n ' '
