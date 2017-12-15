#!/bin/bash
##############################################################################
#     Name: treo.sh
#
#  Summary: Weekly Economist iSilo article transfer & backup automation.
#
#  Created: Sat 02 Dec 2006 10:04:22 (Bob Heckel)
# Modified: Sat 08 Nov 2008 11:43:06 (Bob Heckel)
##############################################################################

PDBPATH=/cygdrive/c/Docume~1/Administrator/Desktop/isilos/
PDBS=$PDBPATH/*.pdb
PDBSEXIST=$(find "$PDBPATH" '*.pdb' -type f -printf "%s" 2>/dev/null)
DRV=f
  
echo '1- has Resco bkup been run on Treo? '
echo "2- is USB drive mounted to $DRV: ?"
echo "3- (optional) have .htm been converted to iSilo .pdb in $PDBPATH dir? "
echo -n 'press enter if yes '
read

if [ -n  "$PDBSEXIST" ];then
  echo "moving .pdb files from Desktop to card's tmp/toread/ ..."
  mv $PDBS /cygdrive/$DRV/tmp/toread
else
  echo
  echo "NOTE: .pdb files do not exist in $PDBPATH (this may be ok)"
fi

echo

echo "copying from card's PALM/BackupE/ to pilotpgms/rescobkup ..."
cp -iR /cygdrive/$DRV/PALM/BackupE/* /home/bheckel/pilotpgms/rescobkup/

# Sysinternals version of sync
# TODO not working on W2K, only XP
$HOME/bin/sync -r $DRV  # flush
###$HOME/bin/sync -e $DRV  # eject

echo '...done'
