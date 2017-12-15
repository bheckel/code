options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: delete_obs.sas
  *
  *  Summary: Delete an observation from an existing dataset.
  *
  *           Usually toggle between this and insert_obs.sas for debugging.
  *
  *  Created: Fri 10 Dec 2004 11:02:53 (Bob Heckel)
  * Modified: Wed 11 Jan 2006 16:01:40 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source NOcenter;

data tmp;
  x=1; y=2;
  output;
  x=3; y=4;
  output;
run;

data tmp;
  set tmp;
  delete;
  put 'never reach here, automatic return to the top after delete';
run;



endsas;
libname L "DWJ2.FET2004.LAST.REVISER.MERGED.FILE";

title 'before';
proc print data=L.data; run;
data L.data;
  set L.data;

  if mergefile eq 'BF19.KYX0402.FETMERZ' then
    delete;
run;
title 'after';
proc print data=_LAST_; run;
