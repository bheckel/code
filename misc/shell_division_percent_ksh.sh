#!/bin/sh

# Simpler probably in bash but this is more portable

function thresholdCk() {
  if [ -z "$1" -o -z "$2" -o -z "$3" ];then
    echo "$fg_redbold error - missing parameter $normal"
  else
    tmin=`echo "scale=0; $2 - $2 * $3" | bc -lwq`
    min=`printf "%.0f" $tmin`
    tmax=`echo "scale=0; $2 + $2 * $3" | bc -lwq`
    max=`printf "%.0f" $tmax`

    if [ $2 -lt $min -o $2 -gt $max ];then
      echo "$fg_redbold fail $2 $normal" 
    else
      echo "pass! $2"
    fi
  fi
}
# Check if result 19 is within 10% of 20
thresholdCk 20 19 0.10
