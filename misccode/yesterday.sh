#!/bin/sh 

# Created: Wed 15 Oct 2008 09:02:22 (Bob Heckel) 

# From datapost_check.sh

# E.g. 09-Sep-2008.zip should exist on 10-Sep-2008
PTHZIP=//rtpsawn445/DataPost/zip_files
MMMYYYY=$(date +%b-%Y)
# E.g. 09
YESTERDAYDD=$(date +%d)
# First remove leading zero, if any, for EXPR calculation
YESTERDAYNUM=$(expr `echo $YESTERDAYDD | sed "s/^0//"` - 1)
# Then see if we have to add it back for the 1st 9 days of month
if [ ${YESTERDAYDD:0:1} = 0 ]; then
  YESTERDAYNUM=0${YESTERDAYNUM}
fi
if [ ! -e "$PTHZIP/${YESTERDAYNUM}-${MMMYYYY}.zip" ];then
  ERROCC=1
  ERRMSG="missing yesterday's zip in $PTHZIP"
  catchError
fi

echo DEBUG "$PTHZIP/${YESTERDAYNUM}-${MMMYYYY}.zip"
