#!/bin/sh

FETCH=
if [ -z "$FETCH" ] && tmp=$(type curl 2>/dev/null) ; then
  FETCH=curl
fi
if [ -z "$FETCH" ] && tmp=$(type wget 2>/dev/null) ; then
  FETCH=wget
fi
if [ -z "$FETCH" ]; then
  echo "ERROR: need \"curl\" or \"wget\""
  errors=yes
fi
