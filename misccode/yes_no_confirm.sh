#!/bin/sh
##############################################################################
#     Name: yes_no_confirm.sh
#
#  Summary: Confirmation yes or no template. rushure?
#
#  Created: Thu 09 Aug 2001 12:54:13 (Bob Heckel)
# Modified: Thu 21 Nov 2002 09:37:52 (Bob Heckel)
##############################################################################

echo -n "Preparing to slay dragon.  Continue? "
read y_or_n

if [ "$y_or_n" = 'y' ] || [ "$y_or_n" = 'Y' ]; then
  echo "$y_or_n = slain"
  for i in $*; do
    echo $i
  done
else
  echo "Canceled.  Exiting."
fi
