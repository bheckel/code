#!/bin/bash
##############################################################################
#     Name: adjust_home_dirs.sh
#
#  Summary: Do changes over several user's home directories.
#
#  Created: Mon 08 Jul 2002 14:37:17 (Bob Heckel)
##############################################################################

for USERDIR in arouse bgreen djustice jjustice mtrotter; do
###for USERDIR in vnetusr; do
  if [ -d $USERDIR ]; then
    mv -v /home/$USERDIR/{.bash_profile,.bash_profileORIG}
    mv -v /home/$USERDIR/{.bash_logout,.bash_logoutORIG}
    ln -s /etc/bash_profile_vnet /home/$USERDIR/.bash_profile
    ln -s /etc/bash_logout_vnet /home/$USERDIR/.bash_logout
    chown $USERDIR /home/$USERDIR/.bash_*
    chmod 644 /home/$USERDIR/.bash_*
  fi
done;
