#!/bin/sh
##############################################################################
#     Name: flopck
#
#  Summary: Check for successful copy to floppy.
#
#  Created: Thu 06 Sep 2001 17:07:37 (Bob Heckel)
# Modified: Fri 26 Jul 2002 08:27:36 (Bob Heckel)
##############################################################################

MIN_EXPECTED_ARGS=1
# User may have typed -h or --help
if [ $# -lt $MIN_EXPECTED_ARGS ]; then
  echo 'usage: flopck localfile_to_compare_with_flop'
  exit 1
fi

harddrv=`cksum $1`
flop=`cksum /mnt/floppy/$1`

compare1=`echo $harddrv | cut -d' ' -f1`
compare2=`echo $flop | cut -d' ' -f1`

if [ "$compare1" = "$compare2" ]; then
  # do nothing
  echo ok
else
  echo 'Warning: checksums do not match!'
fi
