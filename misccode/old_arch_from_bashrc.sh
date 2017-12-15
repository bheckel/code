    # arch() - backup (aka archive) files which have changed in the last N
    # days.  Number of days always INCLUDES TODAY.
    #
    # Copies of arch and unarch tarballs should exist in $TMP as audit trail 
    #
    # Without args, it assumes today is sometime during the workweek and will
    # calculate the days to backup from Monday to current day.  This won't
    # work for the weekend backups.  So use arch -d3 on Sunday night to
    # capture Friday night thru Sunday.
    #
    # 6 5 4 3 2 1
    # S M T W T F S
    # $ arch -d6  run on Friday afternoon will capture changes made today back
    # thru (and including) Sunday.
    #
    # Keep this function in .bashrc or it will fail when it attempts to back
    # itself up.  
    #
    # TODO remove REMOVETHIS__ markers after copying the markers to floppy to
    # avoid accidental deletions
    arch() {
      local now=`date +%Y%m%d`  # e.g. 20040922
      # Use last Sunday unless -d switch is passed to override later.
      local dayspast=`date +%w`   # e.g. Monday is 1, Tuesday is 2, ...

      # Path relative to $HOME.  DON'T use local here.
      f=(.bashrc .vimrc) 
      # Timestamp search descends into all subdirs of these dirs.
      ###d=(readme code)
      d=(code)
      if [ $HOSTNAME = 'sati' ]; then
        drv=f
        archdrv=/cygdrive/$drv/arch
      elif [ $HOSTNAME = 'ZEBWL06A16349' ]; then
        drv=e
        archdrv=/cygdrive/$drv/arch
      else
        echo .bashrc arch ERROR: do not know about this hostname: "$HOSTNAME"
        echo                     add hostname to arch
        echo press enter to quit
        read
        exit 1
      fi

      while getopts uUd: the_option; do
        case "$the_option" in
          u | U )  # Unarch (unpack) the tarball.
                   echo '%~%~%~%~%~%~%~%~%~%~%~%~ua~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~'
                   # If not arch'd today, prompt for confirmation to make sure
                   # we don't untar an old tarball by accident.
                   tnow=`date +%e`
                   ttball=`ls -l $archdrv/arch.tar.gz | awk '{print $7}'`
                   if [ $tnow != $ttball ]; then
                     echo -n 'Tarball date: '
                     tstamp=$(find $archdrv/arch.tar.gz -printf "%TA, %TB %Td" )
                     echo $tstamp
                     echo -n "Today's date: "
                     date '+%A, %B %d'
                     echo -n 'ok? (ctrl-c to abort) '
                     read
                   fi
                   if ! [ `cp $archdrv/arch.tar.gz $TMP/unarch${now}.tar.gz` ]; then
                     ###echo "Unarching $TMP/unarch${now}.tar.gz to c: and $archdrv..."
                     echo "Unarching $TMP/unarch${now}.tar.gz to c: ..."
                     (
                      cd $HOME || return 1
                      tar xvfz $TMP/unarch${now}.tar.gz || return 1
                      # Also synchronize jumpy for backup purposes
                      # TODO swiss jump too small 2007-07-09 
                      ###cd /cygdrive/$drv/cygwin/home/bheckel/ || return 1
                      ###tar xfz $TMP/unarch${now}.tar.gz || return 1
                     )
                     if [ $HOSTNAME = 'sati' ]; then
                       echo "Running allup -s to transfer to sverige..."
                       $HOME/bin/allup -s
                     fi
                   else
                     echo "ERROR: $FUNCNAME cannot cp $TMP/unarch${now}.tar.gz"
                   fi

                   # Make sure we don't miss any files copied by hand.
                   ls -la $archdrv

                   # Sysinternals version of sync
                   $HOME/bin/sync -r $drv  # flush
                   ###$HOME/bin/sync -e $drv  # eject

                   # Clean up rmv'd files.
                   if [ -e $HOME/bin/clean_synch ]; then
                     echo "${fg_purple}Running $HOME/bin/clean_synch ...${normal}"
                     $HOME/bin/clean_synch
                   else
                     echo "warning: $HOME/bin/clean_synch is not available!"
                   fi
                   return 0
                   ;;  # end of unarch
              d )  dayspast="$OPTARG"   # user requested N days of backup
                   ;;
              * )  echo 'Usage: arch [-u -dN]'
                   return 1
                   ;;
        esac
      done # processing switches, if any

      # If we reach there were no switches passed, it's during the workweek so
      # just arch it.

      echo "${fg_redbold}Make sure USB drive is mounted${normal}"
      echo '+»«.»«.»«.»«.»«.»«.»«.»«.»«.»«.»«.»«.»«.»«.»«»«.»«.»«.»«.»«.»«.»«.»«.»«.»«.»«+'

      (
       cd $HOME
       echo " Now tarballing: "
       echo -n $fg_yellow
       ###for the_obj in ${d[@]} ${f[@]}; do
       for the_obj in ${d[@]}; do
         echo "$the_obj/ "
       done
       for the_obj in ${f[@]}; do
         echo "$the_obj "
       done
       echo -n $normal
       echo "...touched during the last $dayspast day(s) (using -daystart)...looking for new files..."
       ###CYGWIN=ntsec  # for 700 permissions when ssh from cdc box
       # Safe for filenames with spaces if use find's -print0 and xarg's -0
       find ${f[@]} ${d[@]} -daystart \( -type f -o -type l \) -mtime \
            -$dayspast ! -name '*.*sw[op]' -print0 | xargs -0 tar cvfz \
	    $TMP/arch${now}.tar.gz
       echo
       echo '+»«.»«.»«.»«.»«.»«.»«.»«.»«.»«.»«.»«.»«.»«.»«»«.»«.»«.»«.»«.»«.»«.»«.»«.»«.»«+'
      )

      # Check for availability of drive before proceeding.
      if ! ( cd $archdrv ); then
        echo If drive $archdrv is really not available, \
             edit .bashrc otherwise check current mounts.  Press ctrl-c
        read
      else
        cp $TMP/arch${now}.tar.gz $archdrv/arch.tar.gz
        # For allup a
        cp $TMP/arch${now}.tar.gz $TMP/arch.tar.gz
      fi
       
      ck1=`cksum $TMP/arch${now}.tar.gz | awk '{print $1}'`
      ck2=`cksum $archdrv/arch.tar.gz | awk '{print $1}'`
      if [ $ck1 != $ck2 ]; then
        echo -n "$FUNCNAME: $fg_redbold cksum FAILURE! $arch${now}.tar.gz $normal may "
        echo 'have floppy trouble.  Continuing...'
      else
        if [ -e "$HOME/bin/align" ]; then
          align "$TMP/arch${now}.tar.gz" '===> checksums agree' 30
        else
          printf " %s \t\t\t\t===> checksums agree\n" arch${now}.tar.gz
        fi
        echo ${fg_purple}confirmation of uncorrupted tarball...${normal}
        tar tfz $archdrv/arch*
      fi

      # Sysinternals version of sync
      $HOME/bin/sync -r $drv  # flush
      # TODO causes corruption after our test for uncorruptedness?
      ###$HOME/bin/sync -e $drv  # eject

      return 0
    } 
