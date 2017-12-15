options dsoptions=note2err;

proc sort data=sashelp.shoes out=t; by region; run;

data t;
  set t;
  /* Commented out to intentionally throw error */
/***  by region;***/
  if first.region ne last.region;
run;
