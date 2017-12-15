#!/bin/sh

# Append to a file if a string does not already exist.

CLIENTDIR=foo

if [ -f /etc/junkbobh ]; then
  ISTHERE=`grep RETROSPECT_HOME /etc/junkbobh`
  if [ ! -z "$ISTHERE" ]; then
    cp /etc/junkbobh /etc/junkbobh.old
    sed -e "/RETROSPECT_HOME/d" < /etc/junkbobh.old > /etc/junkbobh
  fi
  echo "export RETROSPECT_HOME=$CLIENTDIR" >> /etc/junkbobh
fi
