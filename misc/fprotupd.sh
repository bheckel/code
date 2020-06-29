#!/bin/sh
##############################################################################
#     Name: fprotupd.sh
#
#  Summary: Update f-prot virus definitions
#
#           Use allup j to cp the defs to jumpy if not using the automated
#           feature below.
#
#  Created: Sun 20 Feb 2005 13:24:22 (Bob Heckel)
# Modified: Sat 02 Sep 2006 15:26:00 (Bob Heckel)
##############################################################################
  
echo 'Must be connected to Internet.'
echo
echo 'Mount USB drive, if desired, anytime before d/l is completed '
echo '(for mirroring purposes only)'
echo
echo -n 'begin virus update downloads? [y/n] '
read yesno
if [ $yesno = 'n' ]; then 
  exit 1
fi

cd /cygdrive//c/util/f-prot/tmp && \
wget ftp://ftp.f-secure.com/anti-virus/updates/f-prot/dos/macro.def && \
wget ftp://ftp.f-secure.com/anti-virus/updates/f-prot/dos/sign.def && \
wget ftp://ftp.f-secure.com/anti-virus/updates/f-prot/dos/sign2.def && \

###rasdial "'Connection to 645-1026' /d"

# TODO timeout and run anyway if no response from user
echo -n 'was dload ok ? [y/n]'
# TODO ok to use yesno twice?
read yesno
if [ $yesno = 'y' ]; then 
  mv -v * ..
  if [ -e g:/fprot ]; then
    echo 'copying to jumpy on g:'
    cp ../macro.def g:/fprot/
    cp ../sign.def g:/fprot/
    cp ../sign2.def g:/fprot/
  fi
fi

echo 'now run f-prot via icon on desktop, changing to "Scan subdirectories" '
echo 'option and typing "c:\" in the "Search" box'
