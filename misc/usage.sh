#!/bin/sh
##############################################################################
#     Name: usage.sh (s/b symlinked as parms.sh)
#
#  Summary: Provide parameter checks and/or usage messages.  Usually will be
#           called from other pgms, passing $# as NUMACTUALARGS.
#
#           if [ "$#" -lt 1 ]; then 
#             usage $0 4 $# '-y -z [FOO]' '-y fooparm' 'descript here'"
#           fi
#           
#
#  Created: Fri 20 Dec 2002 09:57:35 (Bob Heckel)
# Modified: Tue 30 Mar 2004 10:16:44 (Bob Heckel)
##############################################################################
  
if [ "$#" -lt 1 ]; then 
  cat <<EOT
Usage: $0 mydir
  Recursively delete temp files like a.out *.bak, etc. in given dir 
  E.g. $0 .
EOT
  exit 1
fi

########################################################

if [ "$#" -lt 1 ]; then 
  echo 'MetaUsage: usage NUMEXPECTEDARGS NUMACTUALARGS PARMSDESC EG SYNOPSIS'
  echo "     E.g.: usage \$0 4 \$# '-y -z [FOO]' '-y fooparm' 'descript here'"
  exit 1
fi

PGM=$1
N_EXPECTED_ARGS=$2
N_RECEIVED_ARGS=$3
PARMS=$4
EXAMPLE=$5
SYNOP=$6

echo "Usage: `basename $PGM` $PARMS
  E.g. `basename $PGM` $EXAMPLE
  $SYNOP"

if [ "$N_RECEIVED_ARGS" -ne "$N_EXPECTED_ARGS" ]; then 
  exit 2
else
  exit 0
fi

########################################################

Usage() {
  echo "Usage: `basename $0`"
  echo "        Creates dummy copies for debugging."

  exit 1
}

# Functions must preceed calls.
Usage2() {
  echo "
Usage: `basename $0` <parameter>

  Does nothing exceptionally well. "

  exit 1
}


MIN_EXPECTED_ARGS=1
# User may have typed -h or --help
if [ $# -lt $MIN_EXPECTED_ARGS ]; then
  Usage
  exit 1
fi


########################################################

# Probably best for simple progs:
[ $# -lt 2 ] && echo "Usage: $0 arg1 arg2" && exit 1


########################################################

if [ "$#" -lt 1 -o "$#" -gt 3 ]; then 
  Usage
fi


if [ "$#" = 0 ]; then
  echo 'error: no arguments parms passed - requires at least one arg'
  exit 1
fi
