#!/bin/bash
##############################################################################
# Test harness for fujitiming IWS application.  Confirms the results of the
# IWS output.
##############################################################################

echo "Begin test..."

types=('Cycle Time:' 'Placements:' 'Fiducial Time:')

for thetype in "${types[@]}"; do
  echo "-----TIM $thetype TIM-----"
  grep "$thetype" *.TIM
done

for thetype in "${types[@]}"; do
  echo "-----tim $thetype tim-----"
  grep "$thetype" *.tim
done

echo "Found $(ls *.tim *.TIM | wc | awk '{print $1}') timfiles"

echo "...End test"
