#!/usr/bin/perl
##############################################################################
#     Name: extract_textblock.pl
#
#  Summary: For any known start and endpoints, print the lines in between.
#
#           See also paragraph_search.pl for blocks delimited by paragraph.
#
#  Created: Wed 11 Oct 2006 13:02:42 (Bob Heckel)
##############################################################################
###use strict;
use warnings;

open FH, 'c:/temp/LGI.log' or die "Error: $0: $!";

$i=0;

$firstline=qq/^MPRINT.*PUT _ALL_/;
$lastline=qq/^NOTE:\\s*There were/;

while ( <FH> ) {
  chomp;
  if ( /$firstline/o ) {
    $i=1;
    print "xxxxxx\n";
  }
  elsif ( /$lastline/o ) {
    print "$_\nxxxxxx\n" if $i == 1;
    $i=0;
  } else {
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
