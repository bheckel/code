# Cannot use shebang since CDROM drive varies.
##############################################################################
#      Name: cyg_cd.sh
#
#   Summary: Configure a bare PC for Cygwin-via-CDROM.
#
#            Assumes that c:\cygwin has been copied to a CDROM (at least as
#            much as will fit on a CDROM).
#
#            Assumes CDROM is in drive d: unless param is passed to specify
#            where the CDROM is located.
#            Run this command first-
#            c:> d:\cygwin\bin\bash.exe
#            Then-
#            $ /cygdrive/d/cygwin/bin/bash /cygdrive/d/cygwin/home/bheckel/cyg_cd.sh [cdromdriveletter]
#
#            TODO usage
#
#  Created: Mon 01 Oct 2001 10:51:14 (Bob Heckel)
# Modified: Sat 16 Feb 2002 00:17:50 (Bob Heckel)
##############################################################################

if [ "$@" ]; then
  drv=$1
else
  drv=d  # the usual CDROM drive is d:
  echo
  echo 'Defaulting to CDROM drive d'
fi

echo
echo -n "Setup CygCD (do mounts, mkdirs, cp dotfiles, etc.) from $drv ? "
read y_or_n
if [ $y_or_n != 'y' ]; then
  echo "Canceled.  Exiting."
  exit 1
fi
unset y_or_n

echo 'You  should see a "Success" line at end of script.'
/cygdrive/$drv/cygwin/bin/mount
echo 'To protect against messing with a real Cygwin installation, now '
echo -n 'we will list your current mounts.  Continue? '
read y_or_n
if [ $y_or_n != 'y' ]; then
  echo "Canceled.  Exiting."
  exit 1
fi

if [ -d '/cygdrive/c/cygcd_bobh' ]; then
  echo 'cygcd_bobh directory already exists.  No need to run this script,'
  echo 'you are already set to go.  Exiting.'
  exit 1
fi

# $PATH does not exist in this script.
/cygdrive/$drv/cygwin/bin/mount -s -b $drv:/cygwin /
# Cygwin requirement:
/cygdrive/$drv/cygwin/bin/mount -s -b $drv:/cygwin/bin /usr/bin 
# Cygwin requirement:
/cygdrive/$drv/cygwin/bin/mount -s -b $drv:/cygwin/lib /usr/lib
/cygdrive/$drv/cygwin/bin/mount -s -b c: /c    # convenience
# Create a $HOME on writeable c:  All Cygwin write requests will use this dir
# only.
/cygdrive/$drv/cygwin/bin/mkdir /cygdrive/c/cygcd_bobh || \
         echo 'cygcd_setup.sh: mkdir cygcd_bobh failed.  Do it by hand later.'
# For mutt (among others).
/cygdrive/$drv/cygwin/bin/mkdir /cygdrive/c/cygcd_bobh/tmp || \
         echo 'cygcd_setup.sh: mkdir tmp failed.  Do it by hand later.'
/cygdrive/$drv/cygwin/bin/sleep 2   # give time for dirs to be written
/cygdrive/$drv/cygwin/bin/mount -s -b c:/cygcd_bobh /home/bheckel
# Several pgms need write access to /tmp
/cygdrive/$drv/cygwin/bin/mount -s -b c:/cygcd_bobh/tmp /tmp
# At this point, the only access to /home/bheckel will now be via an explicit
# call such as  cd /cygdrive/d/home/bheckel

# Files that require write access.
/cygdrive/$drv/cygwin/bin/cp -v \
                   /cygdrive/$drv/cygwin/home/bheckel/.Xdefaults /home/bheckel
/cygdrive/$drv/cygwin/bin/cp -v \
                   /cygdrive/$drv/cygwin/home/bheckel/.bashrc /home/bheckel
/cygdrive/$drv/cygwin/bin/cp -v \
                   /cygdrive/$drv/cygwin/home/bheckel/.vimrc /home/bheckel
/cygdrive/$drv/cygwin/bin/cp -v \
                   /cygdrive/$drv/cygwin/home/bheckel/cygwin.bat /home/bheckel

# Default is to copy read-only.
/cygdrive/$drv/cygwin/bin/chmod -R 755 /cygdrive/c/cygcd_bobh/
# Append a hack to avoid having to mess up the master version of .bashrc.
echo 'export PATH=$PATH:/cygdrive/d/cygwin/home/bheckel/bin' \
                                           >> /cygdrive/c/cygcd_bobh/.bashrc

/cygdrive/$drv/cygwin/bin/ln -s \
          /cygdrive/$drv/cygwin/home/bheckel/ /cygdrive/c/cygcd_bobh/bheckel

if [ $drv != 'd' ]; then
  echo
  echo '!!! You must edit c:\cygcd_bobh\cygwin.bat to change the "start d:..."'
  echo "line to $drv: !!!"
fi

echo
echo 'Success.  Now exit this bash session.'
echo 'Here are your mounts:'
/cygdrive/$drv/cygwin/bin/mount
echo 'To run an rxvterm, use c:\cygcd_bobh\cygwin.bat from Windows.'

exit 0
