#!/bin/bash
##############################################################################
#     Name: doubleparens.sh
#
#  Summary: Manipulating a variable, C-style, using the ((...)) construct.
#
#           ----------------- Easter Egg alert!  ----------------- 
#           Chet Ramey apparently snuck a bunch of undocumented C-style
#           constructs into Bash.  In the Bash docs, Ramey calls ((...)) shell
#           arithmetic, but it goes far beyond that.  See also "for" and
#           "while" loops using the ((...)) construct.  These work only with
#           Bash, version 2.04 or later.
#
#  Adapted: Fri 07 Sep 2001 17:06:31 (Bob Heckel--
#                       http://www.linuxdoc.org/LDP/abs/html/dblparens.html)
# Modified: Wed 30 Oct 2002 09:57:39 (Bob Heckel)
##############################################################################

(( a = 23 ))  # Setting a value, C-style, with spaces on both sides of the "=".
echo "a (initial value) = $a"

(( a++ ))     # Post-increment 'a', C-style.
echo "a (after a++) = $a"

(( a-- ))     # Post-decrement 'a', C-style.
echo "a (after a--) = $a"

(( --a ))     # Pre-decrement 'a', C-style.
echo "a (after --a) = $a"
echo

(( t = a<45 ? 7 : 11 ))   # C-style trinary hook operator.
echo "If a < 45, then t = 7, else t = 11."
echo "t = $t "  # Yes!
echo

echo "Only $(( (365-$(date +%j)) / 7 )) weeks til the new yr."

exit 0
