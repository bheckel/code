#!/bin/bash
##############################################################################
#     Name: trap.sh
#
#  Summary: Demo of trapping signals.
#
#  Adapted: Thu 17 May 2001 16:01:13 (Bob Heckel -- p.208 Learning the Bash
#                                     Shell)
# Modified: Fri 14 Aug 2009 13:07:31 (Bob Heckel)
##############################################################################

echo 'Hint: Ctrl-z, jobs, kill'

while : ; do 
  trap "echo 'You tried to kill me!  Sorry Hal, no can do.'" INT
  # E.g. write a large tempfile (that you don't want to strand)
  # ...
  ###trap 'rm -f $TEMPFILE; exit 1' TERM

  # E.g. change perms on a sensitive file (don't let this step get interrupted)
  # trap '' INT QUIT TERM
  # ...
  # Sensitive part is over
  # trap INT QUIT TERM

  sleep 1
  echo -n '.'  # progress bar
done

