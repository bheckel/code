#!/bin/sh

# Cygwin version

[ $# -lt 2 ] && echo "Usage: $0 myexecutable pollingseconds" && exit 1

processToWatch=$( ps -W | grep "$1" | awk '{ print $1 }' )

function watch() {
  while true; do
    sleep $2
    processToCheck=$( ps -W | grep $1 | awk '{print $1}' )
    if [ -z "$processToCheck" -o "$processToWatch" != "$processToCheck" ]; then
      echo "Process $1 is not running"
      return
    fi
  done
}
watch $1 $2
