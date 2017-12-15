options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: character2SASdate.sas
  *
  *  Summary: Convert character to SAS date
  *
  *  Created: Tue 23 Jul 2013 10:23:02 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source NOcenter dsoptions=note2err;

 /* If a new var is ok: */
data t;
  myepochchar='2';
  output;
run;
data t;
  set t;
  myepochnum=input(myepochchar, BEST.);
run;
proc contents; run;
proc print data=_LAST_(obs=max) width=minimum; format myepochnum DATE.; var myepochchar myepochnum; run;


 /* If creating a new var is not ok: */
data t;
  x = '2';
  output;
run;
data t(drop=TMP:);
  set t(rename=(x=TMPx));
  x = input(TMPx, BEST.);
run;
proc contents; run;
proc print data=_LAST_(obs=max) width=minimum; format x DATE.; var x; run;


data t2;
  x = '2011-03-11T04:53:31.723-05:00';  /* char */
  output;
run;

data t2(drop=TMP:);
  format x DATETIME18.;
  set t2(rename=(x=TMPx));
  /* Will NOT work: */
/***  x = input(TMPx, BEST29.);***/
  /* If incoming text isn't recognizable by any SAS format, must scan()/substr() then use dhms() */
  x = input(TMPx, YMDDTTM19.);
run;
proc contents; run;
  /* Converted to real numeric datetime: 24FEB11:21:41:11 */
proc print data=_LAST_(obs=max) width=minimum; run;
