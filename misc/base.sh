#!/bin/bash
##############################################################################
#     Name: base.sh
#
#  Summary: Accept binary, decimal, octal or hexadecimal input then convert 
#           the number into different bases.
#
# Adapted: Fri 14 Sep 2001 16:05:40 (Bob Heckel -- Heiner Steven website
#                                                    heiner.steven@odn.de)
# Modified: Thu 26 Feb 2004 15:07:03 (Bob Heckel)
##############################################################################

PN=`basename "$0"`
VER=`echo '$Revision: 1.2 $' | cut -d' ' -f2`  # e.g. 1.2

Usage() {
    echo "$PN - print number to different bases, $VER
usage: $PN [number ...]

If no number is given, the numbers are read from standard input.
A number may be
    binary (base 2)		starting with b (i.e. b1100)
    octal (base 8)		starting with 0  (i.e. 014)
    hexadecimal (base 16)	starting with 0x (i.e. 0xc)
    decimal			otherwise (i.e. 12)

It may be easier to use bc(1) e.g. obase=16 then type your decimal
or use Vim :echo 0x74 if going hex or oct to dec" 
    >&2
    exit 1
}


Msg() {
  for i
    do echo "$PN: $i" >&2
  done
}


Fatal() { Msg "$@"; exit 66; }


PrintBases() {
  # Determine base of the number
  for i      # in [list] is missing...
  do         # ...so operates on command line arg(s)  (DON'T INDENT do)
  case "$i" in
                   b* )  ibase=2  	# binary
                         i="0$i";;  # keep the sed substitution below happy
    0x*|[a-f]*|[A-F]* )  ibase=16;;	# hexadecimal
                   0* )  ibase=8;;	# octal
               [1-9]* )  ibase=10;;	# decimal
                    * )  Msg "illegal number $i - ignored"
                         continue;;
  esac

  # Remove prefix, convert hex digits to uppercase (bc needs this)
  # Uses ":" as sed separator, rather than "/".
  number=`echo "$i" | sed -e 's:^0[bBxX]::' | tr '[a-f]' '[A-F]'`
  # Convert number to decimal.
  dec=`echo "ibase=$ibase; $number" | bc`

  case "$dec" in
    [0-9]* )         ;;     # number ok
         * ) continue;;	    # error: ignore
  esac

  # TODO pad binary with leading zero(s).
  # Print all conversions in one line.
  # 'here document' feeds command list to 'bc'.
  echo `bc <<EOT
      obase=16; "hex="; $dec
      obase=10; "dec="; $dec
      obase=8;  "oct="; $dec
      obase=2;  "bin="; $dec
EOT
  ` | sed -e 's: :	:g'

  done
} # PrintBases


while [ $# -gt 0 ]; do
  case "$1" in
    -- )  shift; break;;
    -h )  Usage;;
    -* )  Usage;;
     * )  break;;			# first number
  esac   # TODO more error checking for illegal input
  shift
done

if [ $# -gt 0 ]; then
  PrintBases "$@"
else					# read from stdin
  echo 'Enter bin b101010, oct 052, dec 42 or hex 0x2a num.  Ctrl-d to exit'
  while read line; do
    PrintBases $line
  done
fi
