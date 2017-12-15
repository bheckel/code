#!/bin/sh

# usage: $u/gsk/check_DP_logs.sh y
#        $u/gsk/check_DP_logs.sh x DEMO

find /cygdrive/${1}/datapost${2}/code -name 'DataPost*.log' | xargs head -n1
find /cygdrive/${1}/datapost${2}/code -name 'DataPost*.log' | xargs grep -e SYSCC
