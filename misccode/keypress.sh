#!/bin/bash
##############################################################################
#     Name: keypress.sh
#
#  Summary: Detect a user keypress ("hot keyboard").
#
# Adapted: Mon 17 Sep 2001 13:59:31 (Bob Heckel--
#                        http://www.linuxdoc.org/LDP/abs/html/system.html)
##############################################################################

old_tty_settings=$(stty -g)   # save old settings
stty -icanon
Keypress=$(head -c1)          # or $(dd bs=1 count=1 2> /dev/null)

echo
echo "Key pressed was \""$Keypress"\"."

stty "$old_tty_settings"      # restore old settings

exit 0
