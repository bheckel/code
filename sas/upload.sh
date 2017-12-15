#!/bin/sh
##############################################################################
#     Name: upload.sh
#
#  Summary: Upload all files at once to move into production.
#
#  Created: Fri 11 Jul 2003 08:51:41 (Bob Heckel)
# Modified: Wed 16 Jul 2003 16:13:08 (Bob Heckel)
##############################################################################
  
Usage() {
  echo "Usage: `basename $0`
  Uploads all production IntrNet files to mainframe."
  exit 1
}

N_EXPECTED_ARGS=0
PW=Langway3

if [ "$#" -ne $N_EXPECTED_ARGS ]; then 
  Usage
fi


for f in main.html wiz.sas wiz2.sas wiz3.sas qry001.sas
  do
    echo -n "upload $f ([y]/n)"?
    read yn
    if [ "$yn" = 'n' ]; then
      # Try next file.
      continue
    fi
    if [ $f != 'main.html' ]; then
      # Basename for naming convention on the MF.
      g=${f%.*}
      # Mainframe
      $HOME/bin/bftp -pd $f "SAS.INTRNET.PDS($g)" bqh0 158.111.2.21 $PW
    else
      # Z/OS
      $HOME/bin/bftp -pd ../sasweb/main.html /websrv/sasweb/nchs/main.html bqh0 158.111.2.21 $PW
    fi
  done

exit 0
