#!/bin/ksh

# Used to run ChemLMS admin client under Exceed.  Paste in its output to run
# ee.ksh, etc.

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

  # Run this by hand
  echo "export DISPLAY=$DISPLAY && ./ee"
fi
