#!/bin/sh
echo 'wtf? - use u:\do.sql instead'
exit






##############################################################################
#     Name: runsample.sh (symlinked as ~/projects/lelimsxxxres/do)
#
#  Summary:  Automate LINKS debug cycle
#
#            To do multiple samples:
#            $ for i in 217504 219670 230266 217505 219674 230290 217507
#            218533 218515 217509 217508 223272 230291 214411; do ./do -g $i;
#            done
#
#            TODO switch to say do not open sas7bdat after getting
#
#  Created: Wed 20 Sep 2006 16:08:11 (Bob Heckel)
# Modified: Wed 02 May 2007 10:31:12 (Bob Heckel)
##############################################################################

PRINTHELP="echo -c copy to blade, -o open, -l clipboard, -g get only, no switch full run/copy/clip "
IR=lelimsindres01a
SR=lelimssumres01a
EXT=sas7bdat
HAVE=0
if test "$2"; then
  SNUM=$2;
elif test "$1"; then
  SNUM=$1;
else
  SNUM=
fi

if [ "$#" -lt 1 -o ! -e $HOME/bin/sasrun ]; then 
  $PRINTHELP
  exit 0
fi

if [ -e ${SR}$SNUM.${EXT} -a -e ${IR}$SNUM.${EXT} ]; then
  HAVE=1
else
  HAVE=0
fi

Copyds() {
  if [ $HAVE = 1 ]; then
    cp -v ${SR}$SNUM.${EXT} /cygdrive/x/SQL_Loader/${SR}.${EXT} && \
    cp -v ${IR}$SNUM.${EXT} /cygdrive/x/SQL_Loader/${IR}.${EXT} 
  else
    echo ${SR}$SNUM.${EXT} and ${IR}$SNUM.${EXT} do not exist locally
    echo "so getting $SNUM..."
    Sasexec $SNUM
    echo "now run this command again"
    exit 0
  fi
}

Clipboardsql() {
  # Hard return required for Oracle, ';' is not enough.
  echo "select meth_spec_nm,meth_var_nm,meth_peak_nm,lab_tst_desc, lab_tst_meth_spec_desc,summary_meth_stage_nm,meth_rslt_char,meth_rslt_numeric/*,checked_by_user_id,samp_tst_dt,checked_dt*/ from tst_rslt_summary where samp_id=$SNUM ;
  select meth_spec_nm,meth_var_nm,indvl_tst_rslt_time_pt,indvl_meth_stage_nm,indvl_tst_rslt_device,meth_peak_nm,indvl_tst_rslt_val_num,indvl_tst_rslt_val_char,indvl_tst_rslt_location from indvl_tst_rslt where samp_id=$SNUM ;"|putclip
}

Sasexec() {
  if [ -e ./both_by_sample.sas ]; then
    $HOME/bin/sasrun ./both_by_sample.sas $SNUM
  else
    echo ERROR: ./both_by_sample.sas missing
    exit 1
  fi
}

while getopts clogh opt; do
  shift `expr $OPTIND - 1`
  case "$opt" in
     c )  # Copy
          Clipboardsql $SNUM
          echo clipboarded
          echo -n "ok to copy $SNUM to blade? <ctl-c> if not "
          read
          Copyds $SNUM
          exit 0
          ;;
     l )  # cLipboard
          Clipboardsql $SNUM
          exit 0
          ;;
     o )  # Open (i.e. don't want latest version from LIMS)
          if [ $HAVE = 1 ]; then
            echo opening ${SR}$SNUM.${EXT} ${IR}$SNUM.${EXT} ...
            cygstart ${SR}$SNUM.${EXT} && cygstart ${IR}$SNUM.${EXT}
          else
            echo -n "don't have $SNUM yet.  get it? <ctl-c> if no "
            read
            echo running Sasexec on $SNUM ...
            Sasexec $SNUM
            echo -n "ok to open? <ctl-c> if no "
            read
            cygstart ${SR}$SNUM.${EXT} && cygstart ${IR}$SNUM.${EXT}
          fi
          exit 0
          ;;
     g )  # Get LIMS data
          Clipboardsql $SNUM
          echo clipboarded
          if [ $HAVE = 1 ]; then
            echo ${SR}$SNUM.${EXT} and ${IR}$SNUM.${EXT} exist already
            echo -n 'use current (y/n)? '
            read usecurr
            if [ "$usecurr" != 'n' ]; then
              echo opening ${SR}$SNUM.${EXT} ${IR}$SNUM.${EXT} ...
              cygstart ${SR}$SNUM.${EXT} && cygstart ${IR}$SNUM.${EXT}
            else
              echo deleting old ${SR}$SNUM.${EXT} ${IR}$SNUM.${EXT} ...
              mv ${SR}$SNUM.${EXT} $TMP
              mv ${IR}$SNUM.${EXT} $TMP
              echo getting new ${SR}$SNUM.${EXT} ${IR}$SNUM.${EXT} ...
              Sasexec $SNUM
              echo opening ${SR}$SNUM.${EXT} ${IR}$SNUM.${EXT} ...
              cygstart ${SR}$SNUM.${EXT} && cygstart ${IR}$SNUM.${EXT}
            fi
          else
            Sasexec $SNUM
            echo opening ${SR}$SNUM.${EXT} ${IR}$SNUM.${EXT} ...
	    # TODO opening 2 sas sessions instead of 1
            ###cygstart ${SR}$SNUM.${EXT} && sleep 6 && cygstart ${IR}$SNUM.${EXT}
            cygstart ${SR}$SNUM.${EXT}
          fi
          exit 0
          ;;
     * )  $PRINTHELP
    exit 0
          ;;
   esac
done

# Fallthru no switch
if [ $HAVE = 1 ]; then
  echo "$SNUM (HAVE is $HAVE) exists already"
  echo -n 'only copy ok? <ctl-c> if not '
  read
  Clipboardsql $SNUM
  echo running Clipboardsql, Copyds on $SNUM ...
  Copyds $SNUM
  exit 0
else
  echo running Sasexec, Clipboardsql, Copyds on $SNUM ...
fi
Clipboardsql $SNUM
Sasexec $SNUM
echo -n "ok to copy ${SR}$SNUM.${EXT} ${IR}$SNUM.${EXT} to blade? <ctl-c> if not "
read
# Mandatory TODO why?
HAVE=1
Copyds $SNUM
exit 0
