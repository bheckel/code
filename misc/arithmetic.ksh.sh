#!/bin/sh

i=5
i=`expr $i + 1`
echo $i

# Note the backslash!
j=`expr $2 \* 100 / 10`
