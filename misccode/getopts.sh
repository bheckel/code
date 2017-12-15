#!/bin/bash
##############################################################################
#     Name: getopts.sh
#
#  Summary: Demo using getopts to parse command line arguments.
#           For more info:
#           $ help getopts 
#           
#  Adapted: Tue 06 Mar 2001 08:21:55 (Bob Heckel -- from
#                 http://www.oase-shareware.org/shell/goodcoding/cmdargs.html)
# Modified: Tue 08 Aug 2006 12:20:41 (Bob Heckel)
##############################################################################

# Simple.  Detect -c switch:
while getopts c opt; do
  shift `expr $OPTIND - 1`
  case "$opt" in
     c )  cp -v lelimssumres01a$1.sas7bdat /cygdrive/x/SQL_Loader/lelimssumres01a.sas7bdat && \
	  cp -v lelimsindres01a$1.sas7bdat /cygdrive/x/SQL_Loader/lelimsindres01a.sas7bdat 
	  exit 0
          ;;
   esac
done




echo "Number of parameters passed to this pgm, i.e. \$#, is: $#"

# No switches passed.  Numeric comparison so use -lt or -eq instead of < or =
if [ $# -lt 1 ]; then
  echo 'This program does nothing. '
  echo 'Must pass at least one switch.'
  echo "  E.g. $0 -v"
  echo '    or'
  echo "  E.g. $0 -f fooparam"
  echo 'Exiting.'
  exit 1
fi

VFLAG=off
FILENAME=undefined

# This loop runs once for each switch or filename.  If a letter is followed by
# a colon, the option is expected to have an argument.
while getopts vVf:F: the_opt; do
  echo "OPTARG ($OPTARG) is non-null when a colon follows the string. "
  echo 'E.g. f:F:'
  case "$the_opt" in
     v | V )  VFLAG=on;;
     f     )  FILENAME="$OPTARG";;
    \?     )  # Unknown flag, can also use  * )
              echo >&2 \
              "Usage: $0 [-v] [-f filename]"
              exit 1
              ;;
  esac
done

echo "OPTIND is $OPTIND"
# Move argument pointer to next.  I think I need to do this when getopts is
# used in .bashrc...
shift `expr $OPTIND - 1`   # same as shift $(($OPTIND - 1))
# ...or maybe better
# unset OPTIND
echo "now OPTIND is still $OPTIND"

echo "Summary: \$VFLAG is: $VFLAG, parameter passed is: $FILENAME"
