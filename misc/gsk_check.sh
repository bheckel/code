#!/bin/bash

# Modified: Fri 04 Apr 2014 13:44:30 (Bob Heckel)

############ Common START ############## {{{
#
# Globals
DPDEMODIRROOT=/cygdrive/x/datapostDEMO
DPDIRROOT=/cygdrive/z/datapost
DPV2DIRROOT=/cygdrive/z/datapost/data/GSK/BEZulon
GSKDIR=u:/gsk
INTERACTIVE=no
MSGBOX=u:/code/misccode/msgbox
if [ "$HOSTNAME" = 'BEZWL12H26564' ]; then
  SASEXE=C:/PROGRA~1/SASHome/SASFoundation/9.3/sas.exe
elif [ "$HOSTNAME" = 'BEZWL12H29961' ]; then
  SASEXE=c:/PROGRA~1/SASINS~1/SAS/V8/sas.exe
else
  SASEXE=c:/PROGRA~1/SAS/SAS9~1.1/sas.exe
fi
SVRLINKSDEV=prtsawn321
SVRLINKSPRD=prtsawn323
SVRLINKSTST=poksawn557
SVRPATHDEV=/cygdrive/x/DataPost
SVRPATHPRD=/cygdrive/z/DataPost
SVRPATHPUCC=prtsawnv0312/pucc
SVRQT=prtsawn445
TREE=u:/code/misccode/tree
UDRV=u:/
ULS=u:/code/sas/ultimate_log_scanner.sh
UBAKDIR=u:/bkup
UTMPDIR=u:/tmp
WEBSVRPATHPRD=prtsawnv0292



catchError() {
  if [ $ERROCC = 1 ];then
    if [ "$INTERACTIVE" = yes ];then
      $MSGBOX "datapost_check.sh rc: $ERROCC" "$ERRMSG" error
    fi
    echo "$fg_redbold fail! \$ERROCC: $ERROCC \$ERRMSG: $ERRMSG $normal"
  else
    exit $ERROCC
  fi
}


catchWarning() {
  if [ "$INTERACTIVE" = yes ];then
    $MSGBOX "$0 warning" "$ERRMSG" warning
  else
    echo "$fg_yellowbold warning $ERRMSG $normal"
  fi
}


# Hardcoded range - Actual, Low, High e.g. thresholdCk $tm 130 170
thresholdCk() {
  if [ -z "$1" -o -z "$2" -o -z "$3" ];then
    echo "$fg_redbold error - missing parameter $normal"
  else
    if [ $1 -lt $2 -o $1 -gt $3 ];then
      echo "$fg_redbold fail $1 $normal" 
    else
      echo "pass! $1"
    fi
  fi
}


# Relative range - Normal, Actual, Threshold Pct e.g. thresholdCkPct 37 $sz 0.10
thresholdCkPct() {
  if [ -z "$1" -o -z "$2" -o -z "$3" ];then
    echo "$fg_redbold error - missing at least one parameter $normal"
  else
    tmin=`echo "scale=0; $1 - ($2 * $3)" | bc -lwq`
    min=`printf "%.0f" $tmin`
    tmax=`echo "scale=0; $1 + ($2 * $3)" | bc -lwq`
    max=`printf "%.0f" $tmax`

    if [ $2 -lt $min -o $2 -gt $max ];then
      echo "$fg_redbold fail $2 $normal" 
    else
      echo "pass! $2"
    fi
  fi
  ###echo DEBUG parms 1: $1 2: $2 3: $3 min: $min max: $max
}


# Save a copy of last 7 days output data e.g. wgetGenBkup ${DPV2DIRROOT}/MDI ip21_0001e_line8filler sas7bdat 7
# !may be worth just using filesystem drive maps
wgetGenBkup() {
  ###echo DEBUG 1 $1 2 $2 3 $3 4 $4
  wget -O $UTMPDIR/${2}.${3} https://${1}/${2}.${3}

  # Write dynamic SAS code
  cat <<HEREDOC >| $UTMPDIR/t.sas 
  libname l "$UTMPDIR";data l.${2}BKUP(genmax=${4});set l.${2};run;
HEREDOC
   
  $SASEXE -sysin "$UTMPDIR/t.sas" -log "$UTMPDIR/t.log";

  # Prevent wget doing .1 .2 etc tomorrow
  rm $UTMPDIR/${2}.${3}
}


# TODO check for errors
function checkLogViaWeb() {
  ###echo DEBUG 1 $1 2 $2 3 $3
  wget -O $UTMPDIR/${2}.${3} http:${1}/${2}.${3}

  echo $fg_cyan
  $ULS $UTMPDIR/${2}.${3}|grep elapsed
  echo $normal

  rm $UTMPDIR/${2}.${3}
}


###function NowVsThen() {
  ###$RUNCMD >| $UTMPDIR/_cmdCURR
  ###diff -ybB -W80 $UTMPDIR/{$1,$2}
  ###cp $UTMPDIR/{$1,$2}
###}

#
#
########## Common END ############ }}}


############ Ventolin() START ############## {{{
#
#
function Ventolin() {
  PRODUCT=Ventolin_HFA
  ERROCC=0
  ERRMSG=

  echo "$fg_cyan ------------------------------------------------------------------------$normal"
  echo 'Checking Ventolin IDF...'
  echo

  # {{{ Recent mod checks
  PTHVHFA=$SVRPATHPRD/VENTOLIN_HFA/INPUT_DATA_FILES/RAW\ MATERIAL\ \&\ IP\ DATA/
  RMATFILES=$(find "$SVRPATHPRD/Ventolin_HFA/INPUT_DATA_FILES/RAW MATERIAL & IP DATA" -name '*.xls' -mtime -2)
  if ! [ -z "$RMATFILES" ];then 
    ERROCC=1
    ERRMSG="$fg_redbold $RMATFILES recently modified $normal"
    catchWarning
    cp -iv "$SVRPATHPRD/Ventolin_HFA/INPUT_DATA_FILES/RAW MATERIAL & IP DATA/updated_BATCH Production/updated_BatchProductionInfo.xls" /cygdrive/u/bkup/updated_BatchProductionInfo.`date +%d%b%y`.xls
    echo
  else
    echo pass! file in $PTHVHFA not recently modified
    echo
  fi

###  echo "$fg_cyan ------------------------------------------------------------------------$normal"
###  echo 'Checking Ventolin OCD file sizes...'
###  echo
###  PTHVHFA=$SVRPATHPRD/VENTOLIN_HFA/OUTPUT_COMPILED_DATA
###  SASFILES=$(find "$SVRPATHPRD/Ventolin_HFA/OUTPUT_COMPILED_DATA" -name '*.sas7bdat' -mtime -2)
###  if [ -z "$SASFILES" ];then 
###    ERROCC=1
###    ERRMSG="$fg_redbold VHFA sas7bdats $SASFILES stale! $normal"
###    catchError
###    echo
###  else
###    echo pass! VHFA sas7bdats in $PTHVHFA recently updated
###    echo
###  fi
###  # }}}
###
###
###  # {{{ Filesize checks
###  PTHVENOUT=$SVRPATHPRD/$PRODUCT/OUTPUT_COMPILED_DATA 
###  echo -n "$PTHVENOUT (230MB): "
###  sz=$(find $PTHVENOUT -maxdepth 2 -name '*.csv' -print0 | xargs -0 \ls -l | awk '{s+=$6}END{print int(s/1000000)}')
###  thresholdCkPct 230 $sz 0.20
###  echo
###
###
###  PTHPLOT=//$SVRPATHPUCC/plots/Ventolin_HFA/OUTPUT/Formatted/cgm200
###  echo -n "$PTHPLOT (30MB): "
###  sz=$(find $PTHPLOT -maxdepth 1 -name '*.cgm' -print0 | xargs -0 \ls -l | awk '{s+=$6}END{print int(s/1000000)}')
###  thresholdCkPct 30 $sz 0.30
###  echo
###  # }}}
###
###
###  echo "$fg_cyan ------------------------------------------------------------------------$normal"
###  echo 'Checking Ventolin SAS Log...'
###  echo
###  PTHLOG=$SVRPATHPRD/Ventolin_HFA/CODE/Log
###  if [ `grep -c '^AUTOMATIC SYSCC 0' "$PTHLOG/Ventolin_HFA.log"` -ne 1 ];then
###    ERROCC=1
###    ERRMSG="$fg_redbold Log in $PTHLOG holds non-zero SYSCC code $normal"
###    catchError
###    echo
###  else
###    echo 'pass! VHFA Log has SYSCC == 0'
###    echo
###  fi

  # 13-Jan-11 won't work if run spans 2 days like vhfa run does
  ###echo -n 'Ventolin elapsed (245 min): '
  ###tm=$(grep 'minutes elapsed' $SVRPATHPRD/Ventolin_HFA/CODE/log/Ventolin_HFA.log|awk {'print int($7)'})
  ###thresholdCkPct 245 $tm 0.10
}

#
#
############ Ventolin END ############## }}}


############ Serevent() START ############## {{{
#
#
function Serevent() {
  PRODUCT=Serevent_Diskus
  ERROCC=0
  ERRMSG=

  echo "$fg_cyan ------------------------------------------------------------------------$normal"
  echo 'Checking Serevent overnight run...'
  echo
  # {{{ Filesize checks
  PTHSDOUT=$SVRPATHPRD/$PRODUCT/OUTPUT_COMPILED_DATA 
  echo -n "$PTHSDOUT (44MB): "
  sz=$(find $PTHSDOUT -name '*.sas7bdat' -print0 | xargs -0 \ls -l | awk '{s+=$6}END{print int(s/1000000)}')
  thresholdCkPct 44 $sz 0.10
  echo
  # }}}

  # SYSCC, elapsed run time {{{
  PTHLOG=$SVRPATHPRD/$PRODUCT/CODE/Log
  # Log will WARN (4) until 28 dose gets combobatches
  if [ `grep -c '^AUTOMATIC SYSCC 4' "$PTHLOG/$PRODUCT.log"` -ne 2 ];then
    ERROCC=1
    ERRMSG="$fg_redbold Log in $PTHLOG holds non-zero SYSCC code $normal"
    catchError
  fi

  echo -n 'Serevent elapsed (2 min): '
  # "^NOTE" avoids the misleading SAS MPRINT line
  ###tm=$(grep '^NOTE:.*minutes elapsed' $SVRPATHPRD/$PRODUCT/CODE/log/$PRODUCT.log|awk {'print int($11)'})
  # The time portion wraps to a 2nd line, hence this complexity.
  # E.g.:
  # NOTE: 0_MAIN_Serevent_Diskus.sas SYSCC: 0 (\\prtdsntp032\DataPostArchive\Serevent_Diskus\CODE\0_MAIN_Serevent_Diskus.sas ended: 10MAR10:04:34:22 / minutes elapsed: 4.34628333648)
  ###tm1=`awk "/^NOTE: 0_MAIN/,/)/ {print}" $SVRPATHPRD/$PRODUCT/CODE/log/$PRODUCT.log| sed 's/\n//g'|awk '{print $1}'|awk '{print int($1)}'`
  ###tm1=`awk "/elapsed:/,/)/ {print}" $SVRPATHPRD/$PRODUCT/CODE/log/$PRODUCT.log| sed 's/\n//g'|awk '{print $11}'|awk '{print int($1)}'`
  # The string breaks across 2 lines, sed won't remove newline for some reason so using perl
  tm1=`awk "/^NOTE:.*elapsed:/,/)/ {print}" $SVRPATHPRD/$PRODUCT/CODE/log/$PRODUCT.log| perl -pe 'chomp $_'|awk '{print $11}'|awk '{print int($1)}'`
  ###tm2=`echo $tm1 | awk '{print $2}'`
  thresholdCk $tm1 2 10
  echo
  # }}}

  ###echo "$fg_cyan ------------------------------------------------------------------------$normal"
  ###echo 'Checking for non-TSR batches...'
  ###echo
  ###if [ -d '\\prtdscel01dm06\rsh86800$' ]; then
  ###  if [ `sqlplus -S sasreport/sasreport@suprd259 @u:\serevent_batches.sql|grep -c '^no rows selected'` -ne 1 ];then
  ###    echo 'warning - non-TSR batches may exist!'
  ###    catchWarning
  ###  else
  ###    echo 'pass! no rows selected for non-TSR batches'
  ###  fi
  ###fi
  ###
  ###echo
}
#
#
############ Serevent END ############## }}}


############ AdvairHFA() START ############## {{{
#
#
function AdvairHFA() {
  PRODUCT=Advair_HFA
  ERROCC=0
  ERRMSG=

  echo "$fg_cyan ------------------------------------------------------------------------$normal"
  echo 'Checking Advair HFA file freshness...'
  echo
  PTHLINKS=//$SVRPATHPUCC/ADVAIR_HFA/INPUT_DATA_FILES/LINKS_DATA
  METAD=$(find $PTHLINKS -maxdepth 1 -name 'lemetadata_advairhfa.sas7bdat' -not -mtime 0)
  if ! [ -z "$METAD"  ];then 
    ERROCC=1
    ERRMSG="$fg_redbold AdvHFA $PTHLINKS metadata file is stale $normal"
    catchError
  else
    echo pass! $PTHLINKS/lemetadata_advairhfa.sas7bdat is new as of yesterday
    echo
  fi

  AHFAOCD=$(find //$SVRPATHPUCC/ADVAIR_HFA/OUTPUT_COMPILED_DATA/ -maxdepth 1 -name 'analytical_individuals.sas7bdat' -not -mtime 0)
  if ! [ -z "$AHFAOCD"  ];then  # if it was written recently the filename will be in AHFAOCD otherwise blank
    ERROCC=1
    ERRMSG="$fg_redbold AdvHFA $AHFAOCD OCD file is stale $normal"
    catchError
  else
    echo pass! $SVRPATHPUCC/ADVAIR_HFA/OUTPUT_COMPILED_DATA/analytical_individuals.sas7bdat is new as of yesterday
    echo
  fi

  if [ `date +%a` = Wed ];then
    AHFAPLOT=$(find //$SVRPATHPUCC/ADVAIR_HFA/OUTPUT_COMPILED_DATA/PLOTS/mfg_date -maxdepth 1 -name 'CONTENT_WEIGHT_HIGH_60_mfg_date.cgm' -not -mtime 0)
    if ! [ -z "$AHFAPLOT"  ];then
      ERROCC=1
      ERRMSG="$fg_redbold AdvHFA $AHFAOCD PLOT file is stale $normal"
      catchError
    else
      echo pass! weekly AHFA PLOT is new as of yesterday
      echo
    fi
  fi

  echo 'Checking Advair HFA file sizes...'
  echo
  echo -n "$PTHLINKS/lemetadata_advairhfa.sas7bdat (1007MB): "
  sz=$(find $PTHLINKS -maxdepth 1 -name 'lemetadata_advairhfa.sas7bdat' -print0 | xargs -0 \ls -l | awk '{s+=$6}END{print int(s/1000000)}')
  thresholdCkPct 1007 $sz 0.10
  echo

  PTHADVOUT=//$SVRPATHPUCC/ADVAIR_HFA/OUTPUT_COMPILED_DATA
  echo -n "$PTHADVOUT .CSVs (228MB): "
  # Only doing .csv b/c there is sas7bdat garbage in that dir
  sz=$(find $PTHADVOUT -maxdepth 1 -name '*.csv' -print0 | xargs -0 \ls -l | awk '{s+=$6}END{print int(s/1000000)}')
  thresholdCkPct 228 $sz 0.10
  echo
}
#
#
############ ADVAIR END ############## }}}


############ QTrend() START ############## {{{
#
#
function QTrend() {
  PRODUCT=QTrend
  ERROCC=0
  ERRMSG=
   
  echo "$fg_cyan ------------------------------------------------------------------------$normal"
  echo 'Checking QuickTrend webserver uptime...(must login as uxx40032 to establish drive maps if rebooted!)';
  echo
  days=$(systeminfo /U 'wmservice\uxx40032' /P uxx06prod /S "\\\\$SVRQT"|grep 'Up Time'|awk '{print $4}')
  echo -n "$SVRQT "
  thresholdCk $days 3 365
  echo
  echo "$fg_cyan ------------------------------------------------------------------------$normal"
  echo 'Checking QuickTrend web overnight run...'
  echo

  # TODO use a loop for these 4
  PTHQT=//$SVRQT/Data_Trending$/MDI_AEROSOLS/  # {{{
  HTM1=$(find $PTHQT -maxdepth 1 -name 'adtrAEROSOLS.html' -not -mtime 0)
  if ! [ -z "$HTM1"  ];then 
    ERROCC=1
    ERRMSG="$fg_redbold QT $PTHQT adtrAEROSOLS.html is stale $normal"
    catchError
  else
    echo pass! $PTHQT updated as of today
  fi

  echo -n "$PTHQT MDIA jpg (3MB): "
  sz=$(find $PTHQT -maxdepth 1 -name '*.jpg' -print0 | xargs -0 \ls -l | awk '{s+=$6}END{print int(s/1000000)}')
  thresholdCkPct 3 $sz 0.50
  echo
  # }}}

  PTHQT=//$SVRQT/Data_Trending$/Excell/  # {{{
  HTM1=$(find $PTHQT -maxdepth 1 -name 'adtrQUICKLIST.html' -not -mtime 0)
  if ! [ -z "$HTM1"  ];then 
    ERROCC=1
    ERRMSG="$fg_redbold QT $PTHQT is stale $normal"
    catchError
  else
    echo pass! $PTHQT updated as of today
  fi

  echo -n "$PTHQT Excell xls (164KB): "
  sz=$(find $PTHQT -maxdepth 1 -name '*.xls' -print0 | xargs -0 \ls -l | awk '{s+=$6}END{print int(s/1000)}')
  thresholdCkPct 164 $sz 0.40
  echo
  # }}}

  PTHQT=//$SVRQT/Data_Trending$/Solid_Dose/  # {{{
  HTM1=$(find $PTHQT -maxdepth 1 -name 'adtrSOLIDDOSE.html' -not -mtime 0)
  if ! [ -z "$HTM1"  ];then 
    ERROCC=1
    ERRMSG="$fg_redbold QT $PTHQT is stale $normal"
    catchError
  else
    echo pass! $PTHQT updated as of today
  fi

  echo -n "$PTHQT SD jpg (3MB): "
  sz=$(find $PTHQT -maxdepth 1 -name '*.jpg' -print0 | xargs -0 \ls -l | awk '{s+=$6}END{print int(s/1000000)}')
  thresholdCkPct 3 $sz 0.60
  echo # }}}


  echo "$fg_cyan ------------------------------------------------------------------------$normal"
  echo 'Checking QuickTrend webpages...'
  echo
  # QT website - are you up?
  (cd $UTMPDIR && wget --delete-after "http://$SVRQT/BEZ%5Fqtrend/")
  if [ $? -ne 0 ];then
    echo "$fg_redbold fail QT index missing $normal"
  fi

  (cd $UTMPDIR && wget --delete-after "http://$SVRQT/BEZ_qtrend/SOLID_DOSE/adtrSOLIDDOSE.html")
  if [ $? -ne 0 ];then
    echo "$fg_redbold fail adtrSOLIDDOSE $normal"
  fi

  (cd $UTMPDIR && wget --delete-after "http://$SVRQT/BEZ_qtrend/MDPI/adtrMDPI.html")
  if [ $? -ne 0 ];then
    echo "$fg_redbold fail adtrMDPI $normal"
  fi

  (cd $UTMPDIR && wget --delete-after "http://$SVRQT/BEZ_qtrend/MDI_AEROSOLS/adtrAEROSOLS.html")
  if [ $? -ne 0 ];then
    echo "$fg_redbold fail adtrAEROSOLS $normal"
  fi

  (cd $UTMPDIR && wget --delete-after "http://$SVRQT/BEZ_qtrend/Excell/adtrQUICKLIST.xls")
  if [ $? -ne 0 ];then
    echo "$fg_redbold fail adtrQUICKLIST $normal"
  fi

  echo

  echo "$fg_cyan ------------------------------------------------------------------------$normal"
  echo "Checking QuickTrend InfoReports host..."
  ping -n 2 BEZwd07d11953
}
#
#
############ QTrend END ############## }}}


############ Aerosol() START ############## {{{
#
#
function Aerosol() {
  PRODUCT=aerosol_samp_sys
  ERROCC=0
  ERRMSG=
  PTHAERO=//$SVRPATHPUCC/$PRODUCT

  echo "$fg_cyan ------------------------------------------------------------------------"
  echo "Checking Aerosol...$normal"
  echo

  currmo=`date +%b`
  curryr=`date +%Y`
  Jan=1
  Feb=1
  Mar=1
  Apr=2
  May=2
  Jun=2
  Jul=3
  Aug=3
  Sep=3
  Oct=4
  Nov=4
  Dec=4
  currqtr=`eval echo "$"$(echo $currmo)""`

  AEROFILE=asampext_Q${currqtr}${curryr}.csv
  AERO=$(find $PTHAERO -maxdepth 1 -name "$AEROFILE" -not -mtime 0)
  if ! [ -z "$AERO"  ];then 
    ERROCC=1
    ERRMSG="$fg_redbold Aero qtrly $PTHAERO $AEROFILE file is stale $normal"
    catchError
  else
    echo pass! $PTHAERO/$AEROFILE was updated yesterday
  fi

  echo
  echo -n "$PTHAERO $AEROFILE aero csv (100-6000KB): "
  sz=$(find $PTHAERO -maxdepth 1 -name "$AEROFILE" -print0 | xargs -0 \ls -l | awk '{s+=$6}END{print int(s/1000)}')
  thresholdCk $sz 100 6000
  echo

  ###echo "$fg_cyan ------------------------------------------------------------------------$normal"
  ###echo 'Checking aero batch count...'
  ###echo
  ###echo 'Aerosol VHFA (813 batches)'
  ###aerobatches=$(tail -n +2 "$SVRPATHPRD/VENTOLIN_HFA/OUTPUT_COMPILED_DATA/asamp_summary.csv"|cut -d ',' -f1|sort|uniq|wc -l)
  ###thresholdCkPct 700 $aerobatches 0.25
  ###echo
}
#
#
############ Aerosol END ############## }}}


############ Zips() START ############## {{{
#
function Zips() {
  echo "$fg_cyan ------------------------------------------------------------------------$normal"
  echo 'Checking Zips (does not work on 10th of month)...'
  echo

  function zipcheck() {
    # E.g. 09-Sep-2008.zip should exist on 10-Sep-2008
    MMMYYYY=$(date +%b-%Y)
    # E.g. 09
    YESTERDAYDD=$(date +%d)
    # First remove leading zero, if any, for EXPR calculation
    YESTERDAYNUM=$(expr `echo $YESTERDAYDD | sed "s/^0//"` - 1)
    # Then see if we have to add it back for the 1st 9 days of month
    if [ ${YESTERDAYDD:0:1} = 0 ]; then
      YESTERDAYNUM=0${YESTERDAYNUM}
    fi
    if [ ! -e "$1/${YESTERDAYNUM}-${MMMYYYY}.zip" ];then
      if [ `date +%d` = 01 ];then
        echo "skip test - first day of month"
        return
      fi
      # 1st run of the week is Monday at 11pm so there will be no file if we check
      # during the day Monday
      if [ `date +%a` != Mon ];then
        ERROCC=1
        # Double single quote is for msgbox's benefit
        ERRMSG="$fg_redbold missing yesterday's zip in $1 $normal"
        echo
        catchError
      else
        echo "pass! weekend file $1/${YESTERDAYNUM}-${MMMYYYY}.zip was not written (as expected) - wait for Monday night"
      fi
    else
      echo pass! $1 written yesterday night
    fi  
  }
  zipcheck "$SVRPATHPRD/DataPost/zip_files"

  echo
}
#
#
############ Zip END ############## }}}


############ LIMS() START ############## {{{
#
#
function LIMS() {
  echo "$fg_cyan ------------------------------------------------------------------------"
  echo "Checking LIMS databases tnsping..."
  echo "$normal"
  echo
  echo 'Production suprd259'
  tnsping suprd259
  echo

  ###echo 'tns long'
  ###tnsping '(ADDRESS=(COMMUNITY=TCPCOM)(PROTOCOL=TCP)(HOST=prtsh005.corpnet2.com)(PORT=1521))'
  ###echo

  ###ping wmservice
  ###echo
  ###ls -l //Wmservice/enterprise/INFRA/APPS/ORACLE/NETWORK/ADMIN/Tnsnames.ora

  ###ipconfig /all; echo

  ###echo 'lims prod short'
  ###ping prtsh005; echo
  ###echo 'lims prod long'
  ###ping -n 1 prtsh005.corpnet2.com; echo
  ###echo 'lims prod raw IP'
  ###ping -n 1 143.193.6.5; echo

  ###echo "$fg_cyan ------------------------------------------------------------------------"
  ###echo "DB login test (s/b about 5 seconds):$normal"
  ###(cd $GSKDIR
  ###echo "$fg_green"
  ###date
  ###echo "$normal"
  ###sqlplus -S sasreport/sasreport@suprd259 @donothing
  ###echo "$fg_green"
  ###date
  ###echo "$normal"
  ###)

###  echo "$fg_cyan ------------------------------------------------------------------------"
###  echo 'LIMS sar...'
###  echo "$normal"
###  cat <<HEREDOC2
###  normal:
###  Average       11       0       2      86
###
###  current:
###HEREDOC2
###  ssh prtsh005 sar -u 10 3; echo
###
###  echo "$fg_cyan ------------------------------------------------------------------------"
###  echo 'LIMS vmstat...'
###  echo "$normal"
###  echo
###cat <<HEREDOC3
###  normal:
###         procs           memory                   page                              faults       cpu
###    r     b     w      avm    free   re   at    pi   po    fr   de    sr     in     sy    cs  us sy id
###    1     0     0   285470  264869   60   14     0    0     0    0     0   1935  92569   564  13  4 83
###    1     0     0   274412  264754   46   18     0    0     0    0     0   1142   5033   270   0  1 99
###    1     0     0   274412  264754  115    7     0    0     0    0     0   1054   3645   229   2  0 98
###
###  current:
###HEREDOC3
###  ssh prtsh005 vmstat 5 3; echo

  ###echo "$fg_cyan ------------------------------------------------------------------------$normal"
  ###echo 'LIMS users...'
  ###echo
  ###ssh prtsh005 UNIX95= ps -eo user,pid,pcpu,comm | sort -nrbk3 | head -20; echo

  echo "$fg_cyan ------------------------------------------------------------------------"
  echo 'LIMS user count...'
  echo "$normal"
  ssh prtsh005 ps -ef | grep lms_client*|wc -l
  echo

  echo "$fg_cyan ------------------------------------------------------------------------"
  echo 'Checking LIMS server ps -ae...'
  echo "$normal"
  ###for svr in prtsh005 prtsh004 ; do
  for svr in prtsh005; do
    echo 
    echo "$svr should be 1: "
    ssh $svr ps -ae | grep lms_nmgr
    echo
    echo "$svr may be 3: "
    ssh $svr ps -ae | grep java
    echo
    echo "$svr should be 2: "
    ssh $svr ps -ef | grep lms_eval*
    echo
    echo "$svr should be 2: "
    ssh $svr ps -ef | grep lms_schd*
    echo
    echo "$svr should be 4: "
    ssh $svr ps -ef | grep lms_qucp*
    echo
    echo "$svr should be 1: "
    ssh $svr ps -ef | grep lms_lmck*
    echo
    echo "$svr should be 1: "
    ssh $svr ps -ef | grep daemonUCP*
    echo
    ssh $svr uptime

    ssh $svr bdf | awk '{print $5 " " $6}' >| $UTMPDIR/bdfCURR.$svr
    diff -ybB -W140 $UTMPDIR/bdfPREV.$svr $UTMPDIR/bdfCURR.$svr
    cp $UTMPDIR/{bdfCURR.$svr,bdfPREV.$svr}  # setup tomorrow's run
    echo
  done

  echo "$fg_cyan ------------------------------------------------------------------------"
  echo 'Checking LIMS Result errors...'
  echo "$normal"
  cnt=$(ssh prtsh005 find /home/gaaadmin/GAAAdapter/gaa/logs -name 'InspectionRes*error*' -mtime -7 -a -size +0 |wc -l)
  if [ "$cnt" -ne 0 ];then
    echo "$fg_redbold fail! Result error(s) exist in the last 7 days, cnt is $cnt $normal"
    ssh prtsh005 find /home/gaaadmin/GAAAdapter/gaa/logs -name 'InspectionRes*error*' -mtime -7
  else
    echo 'no errors'
  fi
  echo

###  echo "$fg_cyan ------------------------------------------------------------------------$normal"
###  echo 'Checking LIMS Inspection Lot errors...'
###  echo
###  cnt=$(ssh prtsh005 find /opt/QCServer/A.05.00/svr/files -name 'Inspec_Lot-*' -mtime -3 -a -size +0 |wc -l)
###  if [ "$cnt" -ne 0 ];then
###    echo "$fg_redbold fail! Inspec_Lot error(s) exist in the last 3 days, cnt is $cnt $normal"
###    ssh prtsh005 'find /opt/QCServer/A.05.00/svr/files -name 'Inspec_Lot-*' -mtime -3 -exec grep "Error:" {} \; | tail'
###  else
###    echo 'no errors'
###  fi
###  echo

  echo "$fg_cyan ------------------------------------------------------------------------"
  echo 'Checking LIMS /opt/QCServer/A.05.00/svr/files/Error.log for changes in last 3 days...'
  echo "$normal"
  cnt=$(ssh prtsh005 find /opt/QCServer/A.05.00/svr/files -name 'Error.log' -mtime -3 -a -size +0 |wc -l)
  if [ "$cnt" -ne 0 ];then
    echo "$fg_redbold fail! Error(s) exist in the last 3 days, cnt is $cnt $normal"
  ###  ssh prtsh005 'find /opt/QCServer/A.05.00/svr/files -name 'Error.log' -mtime -3 -exec grep "Error" {} \;'
    ssh prtsh005 tail -35 /opt/QCServer/A.05.00/svr/files/Error.log
  else
    echo 'no errors'
  fi
  echo

   echo "$fg_cyan ------------------------------------------------------------------------"
   echo 'Checking LIMS /var/opt/ChemLMS/log/log.ERRORS for changes in last 3 days...'
   echo "$normal"
   cnt=$(ssh prtsh005 find /var/opt/ChemLMS/log/ -name 'log.ERRORS' -mtime -3 -a -size +0 |wc -l)
   if [ "$cnt" -ne 0 ];then
     echo "$fg_redbold fail! SERIOUS ERROR(s) EXIST in the last 3 days, cnt is $cnt $normal"
     ssh prtsh005 tail -60 /var/opt/ChemLMS/log/log.ERRORS
   else
     echo 'no errors'
   fi
   echo
 
   echo "$fg_cyan ------------------------------------------------------------------------"
   echo 'Checking LIMS /home/gaaadmin/GAAAdapter/gaa/send/Control_Input/ last modified times...'
   echo "$normal"
   ssh prtsh005 ls -l /home/gaaadmin/GAAAdapter/gaa/send/Control_Input/
   echo
 
###   echo "$fg_cyan ------------------------------------------------------------------------"
###   echo 'Checking if LIMS /home/gaaadmin/GAAAdapter/gaa/send/Control_Input/InspectionPlan/ is clogged...'
###   echo "$normal"
###   cnt=$(ssh prtsh005 ls -l /home/gaaadmin/GAAAdapter/gaa/send/Control_Input/InspectionPlan/|wc -l)
###   if [ "$cnt" -ne 1 ];then
###     echo "$fg_redbold fail! SERIOUS ERROR MAY exist, cnt is $cnt $normal"
###     ssh prtsh005 ls -l /home/gaaadmin/GAAAdapter/gaa/send/Control_Input/InspectionPlan/
###   else
###     echo 'no errors'
###   fi
###   echo

  echo "$fg_cyan ------------------------------------------------------------------------"
  echo 'Checking if LIMS /home/gaaadmin/GAAAdapter/gaa/send/Control_Input/InspectionResults/ is clogged...'
  echo "$normal"
  cnt=$(ssh prtsh005 ls -l /home/gaaadmin/GAAAdapter/gaa/send/Control_Input/InspectionResults/|wc -l)
  if [ "$cnt" -ne 1 ];then
    echo "$fg_redbold fail! SERIOUS ERROR MAY exist, cnt is $cnt $normal"
    ssh prtsh005 ls -l /home/gaaadmin/GAAAdapter/gaa/send/Control_Input/InspectionResults/
  else
    echo 'no errors'
  fi
  echo

  echo "$fg_cyan ------------------------------------------------------------------------"
  echo 'Checking if LIMS /home/gaaadmin/GAAAdapter/gaa/receive/Output_Data/ (daemonUCP) is clogged...'
  echo "$normal"
  cnt=$(ssh prtsh005 ls -l /home/gaaadmin/GAAAdapter/gaa/receive/Output_Data/|wc -l)
  if [ "$cnt" -ne 2 ];then  # InspectionLot_1_EANCM5034316002019_0000000036503777_20120927_03000014_0.lot can be ignored
    echo "$fg_redbold fail! SERIOUS ERROR MAY exist, cnt is $cnt $normal"
    ssh prtsh005 ls -l /home/gaaadmin/GAAAdapter/gaa/receive/Output_Data/
  else
    echo 'no errors'
  fi
  echo
}
#
#
############ LIMS END ############## }}}


############ LINKS() START ############## {{{
#
#
function LINKS() {
  echo "$fg_cyan ------------------------------------------------------------------------"
  echo "Checking LINKS box uptimes to make sure uxx is still logged in...";
  echo "$normal"
  echo

  days=$(systeminfo /U 'wmservice\uxx19034' /P uxx06test /S "\\\\$SVRLINKSDEV"|grep 'Up Time'|awk '{print $4}')
  echo -n "$SVRLINKSDEV "
  thresholdCk $days 3 365

  days=$(systeminfo /U 'wmservice\uxx19034' /P uxx06test /S "\\\\$SVRLINKSTST"|grep 'Up Time'|awk '{print $4}')
  echo -n "$SVRLINKSTST "
  thresholdCk $days 3 365

  days=$(systeminfo /U 'wmservice\uxx40032' /P uxx06prod /S "\\\\$SVRLINKSPRD"|grep 'Up Time'|awk '{print $4}')
  echo -n "$SVRLINKSPRD "
  thresholdCk $days 3 365
  echo

  echo "$fg_cyan ------------------------------------------------------------------------"
  echo "Making sure LINKS is running...";
  echo "$normal"
  ls -l $z/SQL_Loader/Logs/LGI.log
  echo

  echo "$fg_cyan Making sure LINKS is succeeding (whatever that means for LINKS)...";
  echo "$normal"
  grep 'ABORT' /cygdrive/z/sql_loader/logs/LGI.log
  echo
}
#
#
############ LINKS END ############## }}}


############ DPv1() START ############## {{{
#
#
function DPv1Logs() {
  echo "$fg_cyan ------------------------------------------------------------------------$normal"
  echo 'Checking DPv1 Logs...'
  echo
  echo "$fg_green ----------------------------------------------------------------$normal"
  echo 'Checking Serevent Log...'
  $ULS z:/Datapostarchive/Serevent_Diskus/code/log/Serevent_Diskus.log|grep -v 'You may have unbalanced quotation marks'|grep -v 'Line generated by the CALL EXECUTE routine'|grep -v 'characteristic.*uninit'|grep -v 'SQLXMSG'
  echo "$fg_green ----------------------------------------------------------------$normal"
  echo 'Checking Valtrex Log...'
  $ULS z:/Datapostarchive/Valtrex_Caplets/code/log/Valtrex_Caplets.log|grep -v 'You may have unbalanced quotation marks'|grep -v 'Line generated by the CALL EXECUTE routine'|grep -v 'characteristic.*uninit'|grep -v 'Composite index'
  echo "$fg_green ----------------------------------------------------------------$normal"
  echo 'Checking VHFA Log...'
  $ULS z:/Datapostarchive/Ventolin_HFA/code/log/Ventolin_HFA.log|grep -v 'You may have unbalanced quotation marks'|grep -v 'Line generated by the CALL EXECUTE routine'|grep -v 'characteristic.*uninit'|grep -v 'Invalid argument to function'|grep -v 'Invalid numeric data'|grep -v 'descriptor'
  echo "$fg_green ----------------------------------------------------------------$normal"
  echo

###  echo "$fg_cyan ------------------------------------------------------------------------$normal"
###  echo 'Checking DP FREQS [PREV vs CURR]...';
###  echo
###  echo 'VHFA60 indiv'
###  echo "options nocenter nodate ps=max ls=90;libname l 'z:/DataPostArchive/Ventolin_HFA/OUTPUT_COMPILED_DATA';proc freq data=l.ven60_analytical_individuals;table test/NOCUM NOPERCENT;run;" >| $UTMPDIR/t.sas && $SASEXE -sysin "$UTMPDIR/t.sas" -log "$UTMPDIR\t1.log" -print "$UTMPDIR\t1CURR.lst"; #cat 'u:\tmp\t1.lst'
###  ###\ls -l $UTMPDIR/t1CURR.lst
###  ###\ls -l $UTMPDIR/t1PREV.lst
###  diff -ybB -W150 $UTMPDIR/{t1PREV.lst,t1CURR.lst}
###  cp $UTMPDIR/{t1CURR.lst,t1PREV.lst}  # setup tomorrow's run
###  echo
###
###  echo '------------------------------------------------------------------------'
###  echo 'VHFA200 indiv'
###  echo "options nocenter nodate ps=max ls=90;libname l 'z:/DataPostArchive/Ventolin_HFA/OUTPUT_COMPILED_DATA';proc freq data=l.ven200_analytical_individuals;table test/NOCUM NOPERCENT;run;" >| $UTMPDIR/t.sas && $SASEXE -sysin "$UTMPDIR/t.sas" -log "$UTMPDIR/t2.log" -print "$UTMPDIR\t2CURR.lst";
###  diff -ybB -W150 $UTMPDIR/{t2PREV.lst,t2CURR.lst}
###  cp $UTMPDIR/{t2CURR.lst,t2PREV.lst}
###  echo
###
###  echo '------------------------------------------------------------------------'
###  echo 'Valtrex indiv'
###  echo "options nocenter nodate ps=max ls=90;libname l 'z:/DataPostArchive/Valtrex_Caplets/OUTPUT_COMPILED_DATA';proc freq data=l.valtrex_analytical_individuals;table test/NOCUM NOPERCENT;run;" >| $UTMPDIR/t.sas && $SASEXE -sysin "$UTMPDIR/t.sas" -log "$UTMPDIR/t3.log" -print "$UTMPDIR\t3CURR.lst";
###  diff -ybB -W150 $UTMPDIR/{t3PREV.lst,t3CURR.lst}
###  cp $UTMPDIR/{t3CURR.lst,t3PREV.lst}
###  echo
###
###  echo '------------------------------------------------------------------------'
###  echo 'Valtrex productionANDanalytical'
###  echo "options nocenter nodate ps=max ls=85;libname l 'z:/DataPostArchive/Valtrex_Caplets/OUTPUT_COMPILED_DATA';proc freq data=l.valtrex_productionANDanalytical;table source/NOCUM NOPERCENT;run;" >| $UTMPDIR/t.sas && $SASEXE -sysin "$UTMPDIR/t.sas" -log "$UTMPDIR/t6.log" -print "$UTMPDIR\t6CURR.lst";
###  diff -ybB -W180 $UTMPDIR/{t6PREV.lst,t6CURR.lst}
###  cp $UTMPDIR/{t6CURR.lst,t6PREV.lst}
###  echo
###
###  echo '------------------------------------------------------------------------'
###  echo 'Serevent28 indiv'
###  echo "options nocenter nodate ps=max ls=90;libname l 'z:/DataPostArchive/Serevent_Diskus/OUTPUT_COMPILED_DATA';proc freq data=l.serevent28_analytic_individuals;table test/NOCUM NOPERCENT;run;" >| $UTMPDIR/t.sas && $SASEXE -sysin "$UTMPDIR/t.sas" -log "$UTMPDIR/t4.log" -print "$UTMPDIR\t4CURR.lst";
###  diff -ybB -W150 $UTMPDIR/{t4PREV.lst,t4CURR.lst}
###  cp $UTMPDIR/{t4CURR.lst,t4PREV.lst}
###  echo
###
###  echo '------------------------------------------------------------------------'
###  echo 'Serevent60 indiv'
###  echo "options nocenter nodate ps=max ls=90;libname l 'z:/DataPostArchive/Serevent_Diskus/OUTPUT_COMPILED_DATA';proc freq data=l.serevent60_analytic_individuals;table test/NOCUM NOPERCENT;run;" >| $UTMPDIR/t.sas && $SASEXE -sysin "$UTMPDIR/t.sas" -log "$UTMPDIR/t5.log" -print "$UTMPDIR\t5CURR.lst";
###  diff -ybB -W150 $UTMPDIR/{t5PREV.lst,t5CURR.lst}
###  cp $UTMPDIR/{t5CURR.lst,t5PREV.lst}
###  echo
}
#
#
############ DPv1 END ############## }}}


############ DPv2() START ############## {{{
#
#
function DPv2() {
###  echo "$fg_cyan ------------------------------------------------------------------------$normal"
###  echo "Saving generation backup DPv2 datasets to $UTMPDIR..."
###  echo
###  wgetGenBkup ${DPV2WEBROOT}/MDI ip21_0001e_line8filler sas7bdat 7
###  wgetGenBkup ${DPV2WEBROOT}/MDI ip21_0002e_line8filler sas7bdat 7
###  wgetGenBkup ${DPV2WEBROOT}/MDI ip21_0001t_line8filler sas7bdat 7
###  wgetGenBkup ${DPV2WEBROOT}/MDI ip21_0002t_line8filler sas7bdat 7
###  wgetGenBkup ${DPV2WEBROOT}/MDPI/AdvairDiskus fw_0001e_advairtrade sas7bdat 7
###  wgetGenBkup ${DPV2WEBROOT}/MDPI/AdvairDiskus ods_0002e_advair sas7bdat 7
###  wgetGenBkup ${DPV2WEBROOT}/SolidDose b21_0001e_BEZ01_sdman sas7bdat 7

  echo "$fg_cyan ------------------------------------------------------------------------"
  echo 'Checking DP Logs...'
  echo "$normal"
  echo "$fg_green ----------------------------------------------------------------"
  echo 'Checking DP Extract Log...'
  $ULS $DPDIRROOT/code/DataPost_Extract.log|grep -v 'You may have unbalanced quotation marks'|grep -v 'Line generated by the CALL EXECUTE routine'|grep -v 'characteristic.*uninit'|grep -v 'NOSPOOL is on'|grep -v 'is uninitialized'|grep -v 'Invalid argument to'|grep -v 'NOTE: Unable to open SASUSER.PROFILE'|grep -v 'NOTE: All profile changes will be lost at the end'|grep -v 'NOTE: File WORK.'|grep -v 'BASE data set does not exist. DATA file is being copied to BASE file'|grep -v 'NOTE: The SAS System stopped processing this step because of errors'
  echo "$normal"
  echo "$fg_green ----------------------------------------------------------------"
  echo 'Checking DP Transform Log...'
  $ULS $DPDIRROOT/code/DataPost_Transform.log|grep -v 'You may have unbalanced quotation marks'|grep -v 'Line generated by the CALL EXECUTE routine'|grep -v 'characteristic.*uninit'|grep -v 'NOSPOOL is on'|grep -v 'is uninitialized'|grep -v 'Invalid argument to'|grep -v 'NOTE: Unable to open SASUSER.PROFILE'|grep -v 'NOTE: All profile changes will be lost at the end'|grep -v 'NOTE: File WORK.'|grep -v 'BASE data set does not exist. DATA file is being copied to BASE file'|grep -v 'NOTE: The SAS System stopped processing this step because of errors'|grep -v 'Mathematical operations could'|grep -v 'Limit set by ERRORS= option'
  echo "$normal"
  echo "$fg_green ----------------------------------------------------------------"
  echo 'Checking DP Trend Log...'
  grep 'ERROR:' $DPDIRROOT/code/DataPost_Trend.log|grep -v 'LIMITN='|grep -v 'A subgroup sample size'
  grep '^NOTE: SYSCC:' $DPDIRROOT/code/DataPost_Trend.log
  echo

  echo "$fg_cyan ------------------------------------------------------------------------"
  echo 'Checking DPDEMO Logs...'
  echo "$normal"
  echo "$fg_green ----------------------------------------------------------------"
  echo 'Checking DPDEMO Extract Log...'
  $ULS $DPDEMODIRROOT/code/DataPost_Extract.log|grep -v 'You may have unbalanced quotation marks'|grep -v 'Line generated by the CALL EXECUTE routine'|grep -v 'characteristic.*uninit'|grep -v 'NOSPOOL is on'|grep -v 'is uninitialized'|grep -v 'Invalid argument to'|grep -v 'NOTE: Unable to open SASUSER.PROFILE'|grep -v 'NOTE: All profile changes will be lost at the end'|grep -v 'NOTE: File WORK.'|grep -v 'BASE data set does not exist. DATA file is being copied to BASE file'|grep -v 'NOTE: The SAS System stopped processing this step because of errors'
  echo "$normal"
  echo "$fg_green ----------------------------------------------------------------"
  echo 'Checking DPDEMO Transform Log...'
  $ULS $DPDEMODIRROOT/code/DataPost_Transform.log|grep -v 'You may have unbalanced quotation marks'|grep -v 'Line generated by the CALL EXECUTE routine'|grep -v 'characteristic.*uninit'|grep -v 'NOSPOOL is on'|grep -v 'is uninitialized'|grep -v 'Invalid argument to'|grep -v 'NOTE: Unable to open SASUSER.PROFILE'|grep -v 'NOTE: All profile changes will be lost at the end'|grep -v 'NOTE: File WORK.'|grep -v 'BASE data set does not exist. DATA file is being copied to BASE file'|grep -v 'NOTE: The SAS System stopped processing this step because of errors'|grep -v 'Mathematical operations could'|grep -v 'Limit set by ERRORS= option'|grep -v 'RENAME list has never been referenced'
  echo

  echo "$fg_cyan ------------------------------------------------------------------------"
  echo "Checking GDM view for freshness - ALL PRODUCTS in NL view ($GSKDIR/lift_rpt_results_nl_lastupdt.sql)...$normal";
  (cd $GSKDIR && sqlplus -S gdm_dist_r/slice45read@ukprd860 @lift_rpt_results_nl_lastupdt.sql)
  echo

  echo "$fg_cyan ------------------------------------------------------------------------"
  echo "Checking Diskus OLS CSV record count (PREV vs CURR)..."
  echo "$normal"
  wc -l $DPDIRROOT/data/GSK/BEZulon/MDPI/AdvairDiskus/OLS_0016T_AdvairDiskus.csv >| $UTMPDIR/ols_CURR.txt
  diff -ybB -W180 $UTMPDIR/{ols_PREV.txt,ols_CURR.txt}
  echo

  # 607378 /cygdrive/z/datapost/data/GSK/BEZulon/MDPI/AdvairDiskus/OLS_0016T_AdvairDiskus   607379 /cygdrive/z/datapost/data/GSK/BEZulon/MDPI/AdvairDiskus/OLS_0016T_AdvairDiskus
  x=`diff -ybB -W180 $u/tmp/{ols_PREV.txt,ols_CURR.txt} |perl -pe 's/(^\d+) [^\d+]*(\d+)[^\d+]*(\d+).*/$3-$1/e'`
  echo -n "Checking Diskus OLS CSV record count (PREV vs CURR) has increased..."
  echo "record count change: $x "
  [[ $x -lt 0 ]] && echo "OLS has reduced record count"; ###[[ $x -ge 1 ]] && echo 'ok'
  cp $UTMPDIR/{ols_CURR.txt,ols_PREV.txt}  # setup tomorrow's run
  echo

  echo "$fg_cyan ------------------------------------------------------------------------"
  echo 'Determine max test_end_date for $DPV2DIRROOT/MDPI/AdvairDiskus/OLS_0016T_AdvairDiskus.csv'
  echo "$normal"
  awk -F, '{a[$28]} END{for (i in a)print i;}' $DPV2DIRROOT/MDPI/AdvairDiskus/OLS_0016T_AdvairDiskus.csv |sort |tail -n2 |tac
  echo

  echo "$fg_cyan ------------------------------------------------------------------------"
  echo "Checking GDM view for minmax tst & mfg dates - DP PRODUCTS ONLY ($GSKDIR/BEZ_lift_rpt_results_nl_maxdates.sql)...$normal";
  (cd $GSKDIR && sqlplus -S gdm_dist_r/slice45read@ukprd860 @BEZ_lift_rpt_results_nl_maxdates.sql)
  echo

  echo "$fg_cyan ------------------------------------------------------------------------"
  echo "Checking GDM view for any NULL test_end_date - ALL DP PRODUCTS ($GSKDIR/BEZ_lift_rpt_results_nl_NULL_test_end_date.sql)...$normal";
  (cd $GSKDIR && sqlplus -S gdm_dist_r/slice45read@ukprd860 @BEZ_lift_rpt_results_nl_NULL_test_end_date.sql)
  echo

  echo "$fg_cyan ------------------------------------------------------------------------"
  echo "Checking GDM view (PREV schema copy vs CURR) for schema changes ($GSKDIR/BEZ_lift_rpt_results_nl_schema.sql)...$normal";
  echo
  (cd $GSKDIR && sqlplus -S gdm_dist_r/slice45read@ukprd860 @BEZ_lift_rpt_results_nl_schema.sql)
	echo 'there should be no difference'
  ###diff -ybB -W180 $UTMPDIR/gdmschemaPREV.lst $UTMPDIR/gdmschemaCURR.lst
  diff $UTMPDIR/gdmschemaPREV.lst $UTMPDIR/gdmschemaCURR.lst
  ###cp $UTMPDIR/{gdmschemaCURR.lst,gdmschemaPREV.lst}
  echo

  echo "$fg_cyan ------------------------------------------------------------------------"
  echo "Viewing zerorecs checking output...";
  echo "$normal"
  (cd $GSKDIR && cat zerorecs.txt)
  echo

  echo "$fg_cyan ------------------------------------------------------------------------"
  echo "Checking GDM view for plants sharing same mat codes - SHOULD BE NONE ($GSKDIR/lift_rpt_results_nl_matcod_shared_across_plantcod.sql)...$normal";
  (cd $GSKDIR && sqlplus -S gdm_dist_r/slice45read@ukprd860 @lift_rpt_results_nl_matcod_shared_across_plantcod.sql)
  echo

  echo "$fg_cyan ------------------------------------------------------------------------"
  echo "Checking for MDES LIMS Map updates...";
  echo "$normal"
  echo
  find '//Bredsntp002/uk_gms_wre_data_area/GDM Reporting Profiles/DATAPOST/Verified/BEZ_LIMS_REPORTING_PROFILE.csv' -newer /cygdrive/u/tmp/mdes.timestamp || echo "$fg_redbold !!! LIMS Map changed !!! $normal"
  touch $UDRV/tmp/mdes.timestamp
  echo

  echo "$fg_cyan ------------------------------------------------------------------------"
  echo "Checking for MDES Material Map updates...";
  echo "$normal"
  echo
  find '//Bredsntp002/uk_gms_wre_data_area/GDM Reporting Profiles/DATAPOST/Verified/BEZ_MATERIAL_REPORTING_PROFILE.csv' -newer /cygdrive/u/tmp/matmap.timestamp || echo "$fg_redbold !!! Material Map changed !!! $normal"
  touch $UDRV/tmp/matmap.timestamp
  echo

  echo "$fg_cyan ------------------------------------------------------------------------"
  echo "Checking for MDES LIFT xls updates...";
  echo "$normal"
  echo
  find '//Bredsntp002/uk_gms_wre_data_area/GDM Reporting Profiles/LIFT/BEZ LIFT Reporting Profile/BEZ_LIFT_REPORTING_PROFILE.xls' -newer /cygdrive/u/tmp/mdeslift.timestamp || echo "$fg_redbold !!! MDES LIFT changed !!! $normal"
  touch $UDRV/tmp/mdeslift.timestamp
  echo

  echo "$fg_cyan ------------------------------------------------------------------------"
  echo "Checking for empty (17K) datasets on $DPDIRROOT...";
  echo "$normal"
  find $DPDIRROOT/data -size 17408c | grep '.*sas7bdat$' | grep -v '.*tr_.*'
  echo

###	if [ `date +%a` = Wed ];then
###		echo "$fg_cyan ------------------------------------------------------------------------"
###		echo "Making backup copy of DEMO's config & result xml...";
###		echo "$normal"
###		cp -iv "$DPDEMODIRROOT/cfg/DataPost_Configuration.xml" $UBAKDIR/DataPost_Configuration.DEMO.`date +%d%b%y`.xml && \
###		zip $UBAKDIR/DataPost_Configuration.DEMO.`date +%d%b%y`.xml.zip $UBAKDIR/DataPost_Configuration.DEMO.`date +%d%b%y`.xml && \
###		rm $UBAKDIR/DataPost_Configuration.DEMO.`date +%d%b%y`.xml
###		cp -iv "$DPDEMODIRROOT/cfg/DataPost_Results.xml" $UBAKDIR/DataPost_Results.DEMO.`date +%d%b%y`.xml && \
###		zip $UBAKDIR/DataPost_Results.DEMO.`date +%d%b%y`.xml.zip $UBAKDIR/DataPost_Results.DEMO.`date +%d%b%y`.xml && \
###		rm $UBAKDIR/DataPost_Results.DEMO.`date +%d%b%y`.xml
###		echo
###	fi

  echo "$fg_cyan ------------------------------------------------------------------------"
  echo 'Checking PROD & DEMO Results XML & HTML freshness...'
  echo "$normal"
  cnt=$(find $DPDIRROOT/cfg -maxdepth 1 -name 'DataPost_Results.xml' -not -mtime 0)
  if [ -z "$cnt" ];then  # if true, string is zero length then it's not old but if the filename is returned it's older than today
    echo 'no errors on PROD - Datapost_Results.xml updated in the last 24 hrs:'
    ls -l $DPDIRROOT/cfg/Datapost_Results.xml
    echo
    if [ `date +%a` = Wed ];then
      echo "...so making backup copy of PROD's result xml...";
      echo "$normal"
      cp -iv $DPDIRROOT/cfg/DataPost_Results.xml $UBAKDIR/DataPost_Results.Prod.`date +%d%b%y`.xml && \
      zip $UBAKDIR/DataPost_Results.Prod.`date +%d%b%y`.xml.zip $UBAKDIR/DataPost_Results.Prod.`date +%d%b%y`.xml && \
      rm $UBAKDIR/DataPost_Results.Prod.`date +%d%b%y`.xml
    fi
  else
    echo "$fg_redbold fail! PROD Datapost_Results.xml did not update in last 24 hrs: $normal"
    ls -l $DPDIRROOT/cfg/Datapost_Results.xml
  fi
  echo
  cnt=$(find $DPDIRROOT/cfg -maxdepth 1 -name 'DataPost_Results.html' -not -mtime 0)
  if [ -z "$cnt" ];then  # if true, string is zero length then it's not old but if the filename is returned it's older than today
    echo 'no errors on PROD - Datapost_Results.html updated in the last 24 hrs:'
    ls -l $DPDIRROOT/cfg/Datapost_Results.html
    echo
  else
    echo "$fg_redbold fail! PROD Datapost_Results.html did not update in last 24 hrs: $normal"
    ls -l $DPDIRROOT/cfg/Datapost_Results.html
  fi
  echo

  cnt=$(find $DPDEMODIRROOT/cfg -maxdepth 1 -name 'DataPost_Results.xml' -not -mtime 0)
  if [ -z "$cnt" ];then  # if true, string is zero length then it's not old but if the filename is returned it's older than today
    echo 'no errors on DEMO - Datapost_Results.xml updated in the last 24 hrs:'
    ls -l $DPDEMODIRROOT/cfg/Datapost_Results.xml
    echo
    if [ `date +%a` = Wed ];then
      echo "...so making backup copy of DEMO's result xml...";
      echo "$normal"
      cp -iv $DPDEMODIRROOT/cfg/DataPost_Results.xml $UBAKDIR/DataPost_Results.Demo`date +%d%b%y`.xml && \
      zip $UBAKDIR/DataPost_Results.Demo`date +%d%b%y`.xml.zip $UBAKDIR/DataPost_Results.Demo`date +%d%b%y`.xml && \
      rm $UBAKDIR/DataPost_Results.Demo`date +%d%b%y`.xml
    fi
  else
    echo "$fg_redbold fail! DEMO Datapost_Results.xml did not update in last 24 hrs: $normal"
    ls -l $DPDEMODIRROOT/cfg/Datapost_Results.xml
  fi
  echo
  cnt=$(find $DPDEMODIRROOT/cfg -maxdepth 1 -name 'DataPost_Results.html' -not -mtime 0)
  if [ -z "$cnt" ];then  # if true, string is zero length then it's not old but if the filename is returned it's older than today
    echo 'no errors on DEMO - Datapost_Results.html updated in the last 24 hrs:'
    ls -l $DPDEMODIRROOT/cfg/Datapost_Results.html
    echo
  else
    echo "$fg_redbold fail! DEMO Datapost_Results.html did not update in last 24 hrs: $normal"
    ls -l $DPDEMODIRROOT/cfg/Datapost_Results.html
  fi
  echo

  echo "$fg_cyan ------------------------------------------------------------------------"
  echo "Checking $DPDIRROOT du filesizes (PREV vs CURR)...";
  echo "$normal"
  du -h $DPDIRROOT/data/GSK/BEZulon/|sort -k2 >| $UTMPDIR/dusortCURR
  diff -ybB -W160 $UTMPDIR/dusoprtREV $UTMPDIR/dusortCURR
  cp $UTMPDIR/{dusortCURR,dusoprtREV}
  echo

  echo "$fg_cyan ------------------------------------------------------------------------"
  echo "Checking IP21 Extracts Sunday 90 to 10 (PREV vs CURR)..."
  echo "$normal"
  echo "options nocenter nodate ls=180;libname l 'z:/datapost/data/gsk/BEZulon/mdi';proc sql; select min(ts) as mints format=DATETIME19., max(ts) as maxts format=DATETIME19. from l.IP21_0001E_Line8Filler;" >| $UTMPDIR/ip21e1.sas && $SASEXE -sysin "$UTMPDIR\ip21e1.sas" -log "$UTMPDIR\ip21e1CURR.log" -print "$UTMPDIR\ip21e1CURR.lst"
  diff -ybB -W150 $UTMPDIR/{ip21e1PREV.lst,ip21e1CURR.lst}
  cp $UTMPDIR/{ip21e1CURR.lst,ip21e1PREV.lst}  # setup tomorrow's run
  echo

  echo "$fg_cyan ------------------------------------------------------------------------"
  echo "Checking IP21 Transforms Weekday auto to 0 (PREV vs CURR)..."
  echo "$normal"
  echo "options nocenter nodate ls=180;libname l 'z:/datapost/data/gsk/BEZulon/mdi';proc sql; select min(ts) as mints format=DATETIME19., max(ts) as maxts format=DATETIME19., mean(_23034794_vessel_pres_pv) as mean23034794 from l.ip21_0002t_line8filler;" >| $UTMPDIR/ip21.sas && $SASEXE -sysin "$UTMPDIR\ip21.sas" -log "$UTMPDIR\ip21CURR.log" -print "$UTMPDIR\ip21CURR.lst"
  diff -ybB -W150 $UTMPDIR/{ip21PREV.lst,ip21CURR.lst}
  cp $UTMPDIR/{ip21CURR.lst,ip21PREV.lst}  # setup tomorrow's run
  echo

  echo "$fg_cyan ------------------------------------------------------------------------"
  echo "Checking IP21 Extracts Weekday auto to 0 (PREV vs CURR)..."
  echo "$normal"
  echo "options nocenter nodate ls=180;libname l 'z:/datapost/data/gsk/BEZulon/mdi';proc sql; select min(ts) as mints format=DATETIME19., max(ts) as maxts format=DATETIME19. from l.IP21_0002E_Line8Filler;" >| $UTMPDIR/ip21e2.sas && $SASEXE -sysin "$UTMPDIR\ip21e2.sas" -log "$UTMPDIR\ip21e2CURR.log" -print "$UTMPDIR\ip21e2CURR.lst"
  diff -ybB -W150 $UTMPDIR/{ip21e2PREV.lst,ip21e2CURR.lst}
  cp $UTMPDIR/{ip21e2CURR.lst,ip21e2PREV.lst}  # setup tomorrow's run
  echo

  echo "$fg_cyan ------------------------------------------------------------------------"
  echo "Checking SD B21 Extract Weekday 45 to 0 (PREV vs CURR)..."
  echo "$normal"
  echo "options nocenter nodate ls=180;libname l 'z:/datapost/data/gsk/BEZulon/soliddose';proc sql; select min(timestamp) as min format=DATETIME19., max(timestamp) as max format=DATETIME19. from l.b21_0001e_BEZ01_sdman;" >| $UTMPDIR/b21.sas && $SASEXE -sysin "$UTMPDIR\b21.sas" -log "$UTMPDIR\b21CURR.log" -print "$UTMPDIR\b21CURR.lst"
  diff -ybB -W150 $UTMPDIR/{b21PREV.lst,b21CURR.lst}
  cp $UTMPDIR/{b21CURR.lst,b21PREV.lst}  # setup tomorrow's run
  echo

  echo "$fg_cyan ------------------------------------------------------------------------"
  echo "Checking VHFA B21 Extract Weekday 45 to 0 (PREV vs CURR)..."
  echo "$normal"
  echo "options nocenter nodate ls=180;libname l 'z:/datapost/data/gsk/BEZulon/mdi/albuterol';proc sql; select min(timestamp) as min format=DATETIME19., max(timestamp) as max format=DATETIME19. from l.b21_0001e_BEZ01_vhfa;" >| $UTMPDIR/b21_2.sas && $SASEXE -sysin "$UTMPDIR\b21_2.sas" -log "$UTMPDIR\b21_2CURR.log" -print "$UTMPDIR\b21_2CURR.lst"
  diff -ybB -W150 $UTMPDIR/{b21_2PREV.lst,b21_2CURR.lst}
  cp $UTMPDIR/{b21_2CURR.lst,b21_2PREV.lst}  # setup tomorrow's run
  echo

  echo "$fg_cyan ------------------------------------------------------------------------"
  echo 'Checking DP dev-tst-prd servers free space...'
  echo $normal
  df -h '//prtsawn321/e$'
  df -h '//poksawn557/e$'
  df -h '//prtsawn323/e$'
  echo

  echo "$fg_cyan ------------------------------------------------------------------------"
  echo 'Visual check graphs...'
  echo "$normal"
	echo
	echo 'use BEZ_lift_rpt_results_nl_maxdt_by_longtestname.sql to debug'
  cygstart "//$SVRPATHPRD/data/GSK/BEZulon/MDPI/AdvairDiskus/AdvairDiskus50050mcgblister_CascadeImpaction_Stage1_5_FPmcgblister.png"
  ###cp $UTMPDIR/{treeCURR,treePREV}
  echo
}

function DPv2Timestamps() {
  echo "$fg_cyan ------------------------------------------------------------------------"
  echo 'Checking data tree -tD (PREV vs CURR)...';
  echo "$normal"
  tree -tD $DPDIRROOT/data/ | grep -v 'TR_.*.csv' | grep -v 'tr_.*.sas7bdat' >| $UTMPDIR/treeCURR
  echo 'opening vim for diff...'
  vi -d $UTMPDIR/treePREV $UTMPDIR/treeCURR
  echo '..copying treeCURR->treePREV'
  cp $UTMPDIR/{treeCURR,treePREV}
  echo
}


#
#
############ DPv2() END ############## }}}


############ Retain() ############ {{{
#
#
function Retain() {
  echo "$fg_cyan ------------------------------------------------------------------------"
  echo 'Checking retain db prod_sel_dt...';
  echo "$normal"
  # retain.sql:
  # select nvl(max(prod_sel_dt), to_date('01/01/1900','MM/DD/YYYY')) from retain.fnsh_prod;
  # quit;
  ###(cd $UDRV && sqlplus retain_user/retainu409@suprd581 @retain.sql)
  (cd $GSKDIR && sqlplus -S retain_user/retainpu731@suprd731 @retain.sql)
  echo
}
#
#
#################################### }}}


############ Other() ############ {{{
#
#
function Other() {
  echo "$fg_cyan ------------------------------------------------------------------------"
  echo "Saving resolved IP addresses to $UTMPDIR..."
  echo "$normal"
  date >| $UTMPDIR/ping.txt
  ###ping -n 1 BEZWD08D26987.wmservice.corpnet1.com >> $UTMPDIR/ping.txt
  ###ping -n 1 BEZWL12H29961.wmservice.corpnet1.com >> $UTMPDIR/ping.txt
  ping -n 1 BEZWL12H26564.wmservice.corpnet1.com >> $UTMPDIR/ping.txt
  ping -n 1 prtsawn321.wmservice.corpnet1.com    >> $UTMPDIR/ping.txt
  ping -n 1 poksawn557.wmservice.corpnet1.com    >> $UTMPDIR/ping.txt
  ping -n 1 prtsawn323.wmservice.corpnet1.com    >> $UTMPDIR/ping.txt
  echo '...done'
  echo

  echo "$fg_cyan ------------------------------------------------------------------------"
  echo "Checking free space on $SVRPATHPUCC..."
  echo $normal
  df -h '//prtsawnv0312/e$'
  echo

  if [ `date +%a` = Wed ];then
    echo "$fg_cyan ------------------------------------------------------------------------"
    echo 'Backup Brad Carroll xls to prepare for the day they are accidentally deleted...'
    echo "$normal"
    cp -iv "//$SVRPATHPUCC/Ventolin_HFA/INPUT_DATA_FILES/RAW MATERIAL & IP DATA/updated_BATCH Production/updated_BatchProductionInfo.xls" $UBAKDIR/updated_BatchProductionInfoVHFA.`date +%d%b%y`.xls && \
    zip $UBAKDIR/updated_BatchProductionInfoVHFA.`date +%d%b%y`.xls.zip $UBAKDIR/updated_BatchProductionInfoVHFA.`date +%d%b%y`.xls && rm -f $UBAKDIR/updated_BatchProductionInfoVHFA.`date +%d%b%y`.xls
    cp -iv "//$SVRPATHPUCC/ADVAIR_HFA/INPUT_DATA_FILES/RAW MATERIAL & IP DATA/updated_BATCH Production/updated_BatchProductionInfo.xls" $UBAKDIR/updated_BatchProductionInfoAHFA.`date +%d%b%y`.xls && \
    zip $UBAKDIR/updated_BatchProductionInfoAHFA.`date +%d%b%y`.xls.zip $UBAKDIR/updated_BatchProductionInfoAHFA.`date +%d%b%y`.xls && rm -f $UBAKDIR/updated_BatchProductionInfoAHFA.`date +%d%b%y`.xls
    echo

    echo "$fg_cyan ------------------------------------------------------------------------"
    echo 'Backup Cindy Aggers xls to prepare for the day it is accidentally deleted...'
    echo "$normal"
    cp -iv "//$SVRPATHPUCC/VENTOLIN_HFA/INPUT_DATA_FILES/RAW MATERIAL & IP DATA/updated_VALVE/updated_VALVE_MK98.xls" $UBAKDIR/updated_VALVE_MK98.`date +%d%b%y`.xls && \
    zip $UBAKDIR/updated_VALVE_MK98.`date +%d%b%y`.xls.zip $UBAKDIR/updated_VALVE_MK98.`date +%d%b%y`.xls && rm -f $UBAKDIR/updated_VALVE_MK98.`date +%d%b%y`.xls
    echo
  fi
}
#
#
#################################### }}}


############ Tickets() ############ {{{
#
#
function Tickets() {
  echo "$fg_cyan ------------------------------------------------------------------------"
  echo 'Checking ticket status...';
  echo "$normal"
  wget -O $UTMPDIR/wget.CURR.htm 'http://ithelp-remedy.gsk.com/ars/ITHelpHDupdate/query_ticket.asp?TicketID=UKIM20005078237'
  echo
  diff $UTMPDIR/{wget.CURR.htm,wget.PREV.htm}
  cp $UTMPDIR/{wget.CURR.htm,wget.PREV.htm}
  echo
}
#
#
#################################### }}}


###if [ `date +%a` = Mon -o `date +%a` = Wed -o `date +%a` = Fri ];then
if [ `date +%a` = Fri ];then
  ###echo -n 'run DPv2Timestamps()? '
  ###read yn
  if [ "$yn" = y ]; then
echo 'error: need to modify code, skipping DPv2Timestamps'
    funcarr=(DPv2 Aerosol Retain Other)
  else
    ###funcarr=(DPv2 Aerosol LIMS LINKS Retain Other)
    funcarr=(DPv2 Aerosol Retain Other)
  fi
  echo
else
  ###funcarr=(DPv2 Aerosol LIMS LINKS Retain Other)
  funcarr=(DPv2 Aerosol Retain Other)
  echo
fi

echo "
  $fg_green
  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
   ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    running $0 functions ${funcarr[@]} at `date` ...
   ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  $normal

"

for f in ${funcarr[@]}; do
  $f
done


echo "
  $fg_green
  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
   ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    ... completed $0 functions ${funcarr[@]} at `date`
   ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  $normal

"



# vim: foldmethod=marker: 
