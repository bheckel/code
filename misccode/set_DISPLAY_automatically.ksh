#!/bin/ksh

# HPUX 11 at least 2009-04-17 

if [ ! "$DT" ] ; then
  # Set up the terminal:
  if [ "$TERM" = "" ]
    then
      eval ` tset -s -Q -m ':?hp' `
    else
      eval ` tset -s -Q `
  fi

  stty erase "^H" kill "^U" intr "^C" eof "^D"
  stty hupcl ixon ixoff
  tabs


  # Set DISPLAY
  Thistty=`tty | sed 's:^/dev/::'`
  dis=`
    who -u |
    awk -v Thistty=$Thistty '$2 == Thistty {print $8}' |
    sed 's/:.*$//'
  `

  if [ -z "$dis" ]; then
    unset DISPLAY
  else
    export DISPLAY=$dis":0.0"
  fi

  echo "DISPLAY=$DISPLAY"
fi
