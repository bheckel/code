#!/bin/sh

cd ~/projects/datapost/data
TMPD=/home/rsh86800/tmp/11Apr11_1302538066/datapost/data
mkdir -p $TMPD && find * -type d | while read d; do mkdir ${TMPD}/${d}; done

