#!/bin/sh

# compute tot filesize for a range of dates
touch -t 2005${1}0000 /tmp/t1
touch -t 2005${2}0000 /tmp/t2
find . -name '*mer' -newer /tmp/t1 ! -newer /tmp/t2 |xargs du -k| awk '{s+=$1}END{print s}'
