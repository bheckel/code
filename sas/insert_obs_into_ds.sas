options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: insert_obs_into_ds.sas
  *
  *  Summary: Insert add an observation into an existing dataset.
  *
  *  Created: Fri 10 Dec 2004 11:02:53 (Bob Heckel)
  * Modified: Tue 26 Jul 2011 15:08:40 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source NOcenter;

data t; do i=1 to 10; foo=5; output; end; run;

proc print data=_LAST_(obs=max); run;

data t;
  set t end=e;
  output;  /* important */
  if e then
    do;
      /* Add a record */
      foo=66;
      output;
    end;
run;
proc print data=_LAST_(obs=max); run;



libname L "DWJ2.FET2004.LAST.REVISER.MERGED.FILE";

title 'before';
proc print data=L.data; run;
data L.data;
  set L.data end=e;
  output;  /* very important or whack the final obs in dataset */
  if e then 
    do;
      mergefile='BF19.KYX0400.FETMERZ';
      stabbrev='KY';
      userid='BQH0';
      date_update=datetime();
      output;  /* this record */
    end;
run;
proc sort data=L.data;
  by stabbrev;
run;
title 'after';
proc print data=_LAST_; run;
