#!/usr/pkg/bin/bash

F=dhammapada.txt

TOTLINES=`wc -l $F|awk '{print $1}'`

LINENUM=$[($RANDOM%${TOTLINES})+1]

RND=`sed -n "$LINENUM"p $F | awk -F '|' '{print $1}'`

###echo $RND

perl -pi -e "s/<item>.*/<item><title>$RND<\/title><\/item>/" dhammapada.rss
