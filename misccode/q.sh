#!/bin/bash
##############################################################################
#     Name: q.sh
#
#  Summary: Super query - bang on multiple buggy query hacks
#
#  Created: Tue 25 Jun 2013 15:47:24 (Bob Heckel)
# Modified: Mon 06 Jan 2014 10:27:55 (Bob Heckel)
##############################################################################

_hdr() {
  echo "
               ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
                         ~~~~~~~~~ $1 ~~~~~~~~~ 
               ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
"
}
  
_one() {
  _hdr g

  if [ "$2" = '' ];then
    $HOME/code/misccode/gone.sh "$1"
  else
    $HOME/code/misccode/gone.sh "$1" $2
  fi
}


_loc() {
  _hdr loc

  if [ "$2" = 's' ];then
      locate --ignore-case --database=/var/lib/locatedb.code "$1" |xargs grep sas
  elif [ "$2" = 'o' ];then
      locate --ignore-case --database=/var/lib/locatedb.code "$1" |xargs grep misccode
  else
    locate --ignore-case --database=/var/lib/locatedb.code "$1"
  fi
}


_rme() {
  _hdr readme

  find ~/code/readme |xargs grep -i --color=always "$1"
}


_qr() {
  _hdr qr

  find $HOME/code/misccode -name 'quickref_*' |xargs grep -i --color=always "$1"
}


_all() {
  _one "$1"
  _rme "$1"
  _qr "$1"
  _loc "$1" $2
  echo
  echo -n ...searched $1 $2
}


get_user_input_loop() {
  stopsearch="false"

  until [ "$stopsearch" = "true" ] ; do
    echo "Enter search term or (q) to quit: "
    read usrinp
    usrnextqry=$usrinp

    case "$usrnextqry" in
      q|Q|quit|Quit|QUIT)
        exit 0
      ;;
      *)
        if [ -n "$usrnextqry" ] ; then
          _all "$usrnextqry" | less --RAW-CONTROL-CHARS --quit-if-one-screen
          echo -n "try new search (y/N)? "; read yn
          if [ ! "$yn" = "y" ] ; then
            stopsearch=true
          else
            continue
          fi
        else
          read state
          case "$state" in
            q|Q|quit|Quit|QUIT)
            exit 0
          ;;
          esac
        fi
      ;;
    esac
  done

  return
}
get_user_input_loop
