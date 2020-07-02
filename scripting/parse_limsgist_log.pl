#!/usr/bin/perl
##############################################################################
#     Name: parse_limsgist_log.pl (s/b symlinked as pll)
#
#  Summary: Parse the PUT _ALL_ lines of LGI.log.  
#           Based on extract_textblock.pl
#
#           ./pll | less
#
#  Created: Wed 11 Oct 2006 13:02:42 (Bob Heckel)
# Modified: Fri 13 Oct 2006 10:11:17 (Bob Heckel)
##############################################################################
use strict;
use warnings;

open FH, 'x:/SQL_Loader/Logs/LGI.log' or die "Error: $0: $!";

print "...................................................................\n";

my $i=0;

my $firstline=qq/^MPRINT.*THEN PUT _ALL_/;
my $lastline=qq/^NOTE:\\s*There were/;

while ( <FH> ) {
###while ( <DATA> ) {
  chomp;
  if ( /$firstline/o ) {
    $i=1;
    print ">>>>>>\n\n";
  }
  elsif ( /$lastline/o ) {
    s/WORK\.LELIMSGIST03B/$ENV{fg_green}03b samp_comm_txt$ENV{normal}/;
    s/WORK\.LELIMSGIST03C/$ENV{fg_green}03c lab_tst_meth$ENV{normal}/;
    s/WORK\.LELIMSGIST03D/$ENV{fg_green}03d meth_rslt_char$ENV{normal}/;
    s/WORK\.LELIMSGIST03E/$ENV{fg_green}03e meth_rslt_numeric$ENV{normal}/;
    s/WORK\.LELIMSGIST03F/$ENV{fg_green}03f approved_by_user_id$ENV{normal}/;
    s/WORK\.LELIMSGIST03F2/$ENV{fg_green}03f2 approved_dt$ENV{normal}/;
    s/WORK\.LELIMSGIST03G/$ENV{fg_green}03g proc_stat$ENV{normal}/;
    s/WORK\.LELIMSGIST03H/$ENV{fg_green}03h samp_status$ENV{normal}/;
    s/WORK\.LELIMSGIST03I/$ENV{fg_green}03i checked_dt$ENV{normal}/;
    s/WORK\.LELIMSGIST03J/$ENV{fg_green}03j checked_by_user_id$ENV{normal}/;
    s/WORK\.LELIMSGIST03T/$ENV{fg_green}03t samp_tst_dt$ENV{normal}/;
    s/WORK\.LELIMSGIST03L/$ENV{fg_green}03l txt_limit$ENV{normal}/;
    s/WORK\.LELIMSGIST03M/$ENV{fg_green}03m matl_nbr\/batch_nbr$ENV{normal}/;
    s/WORK\.LELIMSGIST03N/$ENV{fg_green}03n stability_study_nbr_cd$ENV{normal}/;
    s/WORK\.LELIMSGIST03O/$ENV{fg_green}03o summary_meth_stage_nm$ENV{normal}/;
    s/WORK\.LELIMSGIST03P/$ENV{fg_green}03p meth_peak_nm$ENV{normal}/;
    s/WORK\.LELIMSGIST03U/$ENV{fg_green}03u prod_nm$ENV{normal}/;

    s/WORK\.LELIMSGIST03V/$ENV{fg_cyan}03v samp_tst_dt-lab_tst_meth-proc_stat-checked_dt-checked_by_user_id->TRS$ENV{normal}/;
    s/WORK\.LELIMSGIST03W/$ENV{fg_cyan}03w LimitsRsltsMerge->TRS$ENV{normal}/;

    s/WORK\.LELIMSGIST04A/$ENV{fg_purple}04a Meth_Peak_Nm$ENV{normal}/;
    s/WORK\.LELIMSGIST04B/$ENV{fg_purple}04b Indvl_Meth_Stage_Nm$ENV{normal}/;
    s/WORK\.LELIMSGIST04C/$ENV{fg_purple}04c Indvl_Tst_Rslt_Nm$ENV{normal}/;
    s/WORK\.LELIMSGIST04D/$ENV{fg_purple}04d Indvl_Tst_Rslt_Device$ENV{normal}/;
    s/WORK\.LELIMSGIST04E/$ENV{fg_purple}04e Indvl_Tst_Rslt_Location$ENV{normal}/;
    s/WORK\.LELIMSGIST04F/$ENV{fg_purple}04f Indvl_Tst_Rslt_Time_Pt$ENV{normal}/;
    s/WORK\.LELIMSGIST04G/$ENV{fg_purple}04g Indvl_Tst_Rslt_Val_Num$ENV{normal}/;
    s/WORK\.LELIMSGIST04H/$ENV{fg_purple}04h Indvl_Tst_Rslt_Val_Char$ENV{normal}/;
    s/WORK\.LELIMSGIST04I/$ENV{fg_purple}04i Indvl_Tst_Rslt_Prep$ENV{normal}/;

    s/WORK\.LELIMSGIST03Q/$ENV{fg_red}03q StudyMerge$ENV{normal}/;
    s/WORK\.LELIMSGIST03R/$ENV{fg_red}03r ApprdtMatlMerge$ENV{normal}/;
    s/WORK\.LELIMSGIST03S/$ENV{fg_red}03s QplusRmerge->Samp$ENV{normal}/;

    s/WORK\.LELIMSGIST05B/05b Samp/;
    s/WORK\.LELIMSGIST05C/05c TRS/;
    s/WORK\.LELIMSGIST05D/05d ST/;
    s/WORK\.LELIMSGIST05E/05e ITR/;

    print "$_\n\n<<<<<<\n\n" if $i == 1;
    $i=0;
  } else {  # body
    print "$_\n" if $i == 1;
  }
}


__DATA__

NOTE: There were 1144 observations read from the data set WORK.LELIMSGIST03E.
NOTE: DATA statement used:
      real time           0.01 seconds
      user cpu time       0.01 seconds
      system cpu time     0.00 seconds
      Memory                            97k
      

MPRINT(TRNLIMSS):   DATA _NULL_;
MPRINT(TRNLIMSS):  SET lelimsgist03l;
MPRINT(TRNLIMSS):  IF SAMP_ID IN (203988) THEN PUT _ALL_;
MPRINT(TRNLIMSS):  RUN;

SAMP_ID=203988 Lab_Tst_Desc=Appearance Lab_Tst_Meth_Spec_Desc=Appearance Low_Limit=. Meth_Peak_Nm=NONE
Meth_Spec_Nm=APPEARDESCRIP Meth_Var_Nm=APPEARDESCRIP$
Txt_Limit_A=Pink, film coated, rounded triangular tablet with gsk debossed on one side and 4/4 on the other side
Txt_Limit_B=  Txt_Limit_C=  Upr_Limit=. Summary_Meth_Stage_Nm=NONE ROWIX=. COLUMNIX=. _ERROR_=0 _N_=1966
SAMP_ID=203988 Lab_Tst_Desc=Individual Total Unspecified Impurity Lab_Tst_Meth_Spec_Desc=Impurities Low_Limit=.
Meth_Peak_Nm=TOTALUNSPECIFIEDIMPURITIES Meth_Spec_Nm=ATM02006ASSAYHPLC Meth_Var_Nm=TOTALUNSPECIFIEDIMPURITIES
Txt_Limit_A=N/A Txt_Limit_B=  Txt_Limit_C=  Upr_Limit=. Summary_Meth_Stage_Nm=NONE ROWIX=. COLUMNIX=. _ERROR_=0 _N_=1971
NOTE: There were 2891 observations read from the data set WORK.LELIMSGIST03L.
NOTE: DATA statement used:
      real time           0.03 seconds
      user cpu time       0.01 seconds
      system cpu time     0.01 seconds
      Memory                            99k
      

MPRINT(TRNLIMSS):   PROC SORT DATA=lelimsgist03d nodupkey;
MPRINT(TRNLIMSS):   BY Samp_Id Meth_Spec_Nm Meth_Var_Nm Meth_Peak_Nm Summary_Meth_Stage_Nm Lab_Tst_Desc 
Lab_Tst_Meth_Spec_Desc;
MPRINT(TRNLIMSS):  foo;
