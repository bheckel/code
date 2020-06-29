#!/bin/bash
##############################################################################
#     Name: align
#
#  Summary: Align data by emulating Perl's repetition operator 'x'.
#
#  Created: Tue 03 Dec 2002 08:27:17 (Bob Heckel)
# Modified: Sat 22 May 2004 19:13:07 (Bob Heckel)
##############################################################################

# TODO
if [ "$#" -lt 2 ]; then 
  echo "usage: $0 STARTWORD ENDWORD NUMBER [PADCHAR]"
  echo "       e.g.  dhamma wheel 40 X"
  exit 1
fi

str="$1"
str2="$2"
howwide=$3  # total desired output width
padchar=$4  # optional

# Space is default.
if [ -z $padchar ]; then
  padchar="\x20"
fi
i=

#                     ______
strlength=`expr ${#str} - 1`    # non-portable bash only!
calcpad=`expr $howwide - $strlength`

for i in `seq $calcpad`; do
  str="${str}${padchar}"
done

# Must use %b for interpretation of backslashed chars.
printf "%b %b\n" "$str""$str2"

exit 0;
