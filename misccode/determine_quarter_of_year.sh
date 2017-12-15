#!/bin/bash

currmo=`date +%b`

Jan=1
Feb=1
Mar=1
Apr=2
May=2
Jun=2
Jul=3
Aug=3
Sep=3
Oct=4
Nov=4
Dec=4

qtr=`eval echo "$"$(echo $currmo)""`
echo "$currmo quarter is $qtr"
