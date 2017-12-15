#!/bin/bash
##############################################################################
#     Name: vitalnet-refresh.sh
#
#  Summary: Automate the executable upgrade and data refresh process for 
#           the Vitalnet application.
#
#           It is assumed that this program will be  used 3 ways:
#             1.  $ vitalnet-refresh.sh -ur  (interactive)
#                 Daniel Goldman provides us with a Vitalnet upgrade tarball
#             2.  $ vitalnet-refresh.sh -r  (interactive)
#                 A new input file requires an import during the day.
#                 (can combine 1 and 2 with -ur)
#             3.  Daily (MTWRF) update (cron)
#                 Reimport 2 years during the night.
#                 Sample crontab line:
#                 06 * * * * VITALNET=/usr/local/ehdp/vn; export VITALNET;
#                 /usr/local/bin/vitalnet-refresh -cr >|
#                 /home/bqh0/public/vnet_cron_err 2>&1
#
#                 TODO have Vitalnet write to stderr, don't think it's doing
#                 that now, hence the 2>&1
#                 TODO specify years to update on the command line
#
#  Created: Wed 15 May 2002 10:33:22 (Bob Heckel)
# Modified: Thu 16 May 2002 08:39:45 (Bob Heckel)
# Modified: Wed 05 Jun 2002 10:53:11 (Bob Heckel -- Daniel has replaced
#                                     import1.ss with daeb-eg10.ss)
# Modified: Fri Jun 14 14:57:45 2002 (Bob Heckel -- use this script from 
#                                     within cron as well as interactively)
# Modified: Mon Jul 22 09:25:16 2002 (Bob Heckel -- change filenames as a
#                                     result of Daniel's modifications)
##############################################################################
# Defaults to be overridden as necessary:
#
# yes or no. If yes, use a smaller set of data and don't save a copy of .tgz.
DEBUG=no
###YEARSARRAY=(2001 2002)                # normally only dealing with 2 years
YEARSARRAY=(1999 2000 2001 2002)                # normally only dealing with 2 years
NUMYRS=${#YEARSARRAY}                 # usually will be 2 (may be overridden)
VN_PATH='/usr/local/ehdp/'            # unpack tarball from here
VN_PATH_OLD='/usr/local/ehdp/tmp/old' # store prior versions of Vitalnet
###VN_TARBALL='usu1-eg2.tgz'             # as specified by Vitalnet developer
VN_TARBALL='usu1-eg4.tgz'             # as specified by Vitalnet developer
CRON=no                               # default is interactive use
CRONSWITCH=                           # -c if running under cron
UPGRADE=no                            # default is 'do not upgrade executables'
REFRESH=no                            # default is 'do not refresh data'
###IMPORT_SCRIPT='vn/ssdir/daeb-eg2.ss'  # daeb-eg10.ss [-c] 2002 MORMED.YR200.NEW
IMPORT_SCRIPT='vn/ssdir/daeb-eg4.ss'  # daeb-eg10.ss [-c] 2002 MORMED.YR200.NEW


Usage() {
  echo
  echo 'Error -- missing switch.  Please use -u, -r, -ur or -cr'
  echo
  echo "Usage: $0 [-cur]"
  echo "       -u  Updates Vitalnet executable from tarball $VN_TARBALL  \"UPGRADE\""
  echo "       -r  Reimports $NUMYRS years of MORMED.YRnnnn.NEW data  \"REFRESH\""
  echo "       -ur Update then Reimport, same as -u -r  \"UPGRADE REFRESH\""
  echo "       -cr Reimport data from within cron  \"CRON REFRESH\""
  echo

  exit 1
}


# User must pass at least one switch.
if [ $# -eq 0 ]; then
  Usage
  # Exit
fi
 
while getopts cCuUrR: the_option; do
  case "$the_option" in
     c | C )  CRON=yes;;
     u | U )  UPGRADE=yes;;
     r | R )  REFRESH=yes;;
         * )  Usage;;
  esac
done

# Specific years of interest to be processed are not always the 2 assumed
# earlier in this pgm.
# TODO allow user to pass in desired year range.
if [ "$UPGRADE" = 'yes' ]; then
  # Daniel's Vitalnet executable upgrades always require a full reimport.
  YEARSARRAY=(1999 2000 2001 2002)  # redefine
  NUMYRS=${#YEARSARRAY}             # redefine
elif [ "$DEBUG" = 'yes' ]; then
  YEARSARRAY=(2002)                 # redefine
  NUMYRS=${#YEARSARRAY}             # redefine
fi

# Can't -c by itself; it has no meaning.
if test "$UPGRADE" = 'no' && test "$REFRESH" = 'no'; then
  Usage
  # Exit
fi

if test "$CRON" = 'no' && test "$USER" != 'bboswell'; then
  echo "You are logged in as $USER"
  echo 'You must be bboswell to run this script.  Sorry.  Exiting.'
  exit 2;
fi

if [ "$CRON" = 'yes' ]; then
  # Vitalnet only reports errors to stderr when -c is passed to it.
  CRONSWITCH=-c    # redefine
fi

# The prompts are silently discarded when used under cron.  I've left them in
# to help during interactive debugging of -cr
echo
echo '***************'
if [ "$UPGRADE" = 'yes' ]; then
  if [ "$REFRESH" = 'no' ]; then
    echo 'You should refresh the datafiles after each Vitalnet upgrade.'
  fi
  echo
  echo 'Upgrade Assumption: '
  echo "   /tmp/$VN_TARBALL exists and is the most recent version of Vitalnet "
  echo '   to be installed.  ' 
fi
if [ "$REFRESH" = 'yes' ]; then
  echo
  echo 'Refresh Assumption: '
  echo '   Years of interest are: '   
  for year in "${YEARSARRAY[@]}"; do
    echo -n "   $year "
  done;
  echo
  echo "   Those years have input files in ${VN_PATH}tmp and are named "
  echo '   using a format identical to this example: MORMED.YR2001.NEW'
fi
echo '***************'
echo -n 'Continue? ([y]/n) '

read y_or_n
if [ "$y_or_n" = 'n' ]; then
  echo 'Cancelled.  Exiting.'
  exit 3
fi

if [ "$UPGRADE" = 'yes' ]; then
  cd $VN_PATH || exit 4
  tar xvfz /tmp/$VN_TARBALL && echo "Successfully untarred $VN_TARBALL" \
                                    " to: $PWD"
  # Archive and datestamp the tarball just in case.
  TODAYDT=`date +%Y%m%d`
  # Can't move from /tmp since it's not owned by Brenda.  Overwriting is
  # ok though.
  # Visually distinguisth chatter from this program to keep separate from 
  # Vitalnet's chatter.
  echo "[35m $0: [0m Copying /tmp/$VN_TARBALL to" \
       "$VN_PATH_OLD/${VN_TARBALL}${TODAYDT}"
  if test "$DEBUG" = 'no'; then
    cp /tmp/$VN_TARBALL $VN_PATH_OLD/${VN_TARBALL}${TODAYDT}
  fi
  echo "[35m $0: [0m =-=-Upgrade completed successfully-=-="
  echo
fi

if [ "$REFRESH" = 'yes' ]; then
  for year in "${YEARSARRAY[@]}"; do
    echo -n "[35m $0:[0m Begin importing $year (this will probably "
    echo "take a while)..."
    # Provide visual confirmation to user.
    echo "[35m $0: [0m Currently running this import command:"
    echo ${VN_PATH}${IMPORT_SCRIPT} $CRONSWITCH $year ${VN_PATH}tmp/MORMED.YR$year.NEW
    echo
    # TODO make more generic, avoid hardcoding
    ${VN_PATH}${IMPORT_SCRIPT} $CRONSWITCH $year ${VN_PATH}tmp/MORMED.YR$year.NEW \
                   && echo "[35m $0: [0m  Year $year has been refreshed."
  done
  echo "[35m $0: [0m =-=-Full refresh completed successfully-=-="
  echo
fi

exit 0
