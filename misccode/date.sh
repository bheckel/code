#!/bin/bash

# Date pieces:

DATE=`date '+%Y%m%d'`
DAY=`date '+%d'`
HOUR=`date '+%H'` 
MONTH=`date '+%m'`
MIN=`date '+%M'`

echo $DATE
echo $DAY
echo $HOUR
echo $MONTH
echo $MIN

if [ $HOUR -eq 11 -a $MIN -ge 45 ]; then
  echo LUNCH
elif [ $HOUR -eq 12 -a $MIN -le 30 ]; then
  echo LUNCH
elif [ $HOUR -eq 16 -a $MIN -ge 25 ]; then
  echo LEAVE
fi
