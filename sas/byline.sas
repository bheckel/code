options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: byline.sas
  *
  *  Summary: SAS option that provides header lines between groups using the
  *           magic "#BYLINE" and "#BYVAL" keywords.
  *
  *  Created: Fri 13 Jun 2003 14:54:50 (Bob Heckel)
  * Modified: Tue 16 May 2006 08:26:51 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source NObyline;


data sample;
   input density  crimerate  state $ 14-27  stabbrev $ 29-30;
   cards;
264.3 3163.2 Pennsylvania   PA
51.2 4615.8  Minnesota      MN
55.2 4271.2  Vermont        VT
9.1 2678.0   South Dakota   SD
102.4 3371.7 North Carolina NC
9.4 2833.0   North Dakota   ND
120.4 4649.9 North Carolina NC
  ;
run;
proc sort data=sample (where=(state like 'North%'));
  by state;
run;


title "#BYLINE";
title2 "#BYVAL(state)";
proc print;
  by state;
run;
