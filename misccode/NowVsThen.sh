#!/bin/sh

RUNCMD=date

NowVsThen() {
  $RUNCMD > $TEMP/_cmdCURR
  diff -ybB -W80 $TEMP/{_cmdCURR,_cmdPREV}
  cp $TEMP/{_cmdCURR,_cmdPREV}

  return
}
NowVsThen
