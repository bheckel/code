#!/bin/bash
##############################################################################
#     Name: vnet_each_home_dir.sh
#
#  Summary: Create a new directory for each user in /home
#           Each Debian reboot clears out everything in /tmp
#           this replaces the user's directories.
#
#           Run as root.
#
#  Created: Fri 05 Jul 2002 10:01:41 (Bob Heckel)
##############################################################################

mkdir /tmp/vitalnet_output || exit 1
chmod 775 /tmp/vitalnet_output

for USERDIR in /home/*; do
  if [ -d $USERDIR ]; then
    NEWDIRBNAME=`basename $USERDIR`
    mkdir /tmp/vitalnet_output/${NEWDIRBNAME}
  fi
done;
chmod 777 /tmp/vitalnet_output/*

# Create the marker file to identify the proper drive map:
echo 'This file is used as a marker for map_to_daeb.bat
The bat file checks for the existence of this file prior to mapping.
Please do not delete.

Bob Heckel 2002-07-05' > /tmp/vitalnet_output/VITALNET_OUTPUT_FOLDER.txt
chmod 644 /tmp/vitalnet_output/VITALNET_OUTPUT_FOLDER.txt

exit 0
