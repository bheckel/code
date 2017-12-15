options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: merge_alternative_to_proc_transpose.sas
  *
  *  Summary: Comparison of a self merge with proc transpose
  *
  *  Adapted: Mon 06 Jul 2009 13:38:34 (Bob Heckel -- 234-2008 SUGI)
  *---------------------------------------------------------------------------
  */
options source NOcenter;

options fullstimer;

data t;
  infile cards;
  input account_no yyyy_mm mnthend_bal cred_lim;
  cards;
111 200505 100 800
111 200506 200 801
222 200505 150 4200
222 200506 120 5000
333 200505 400 2500
333 200506 600 2500
  ;
run;
proc print data=_LAST_(obs=max) width=minimum; run;

 /* We want a 'wide' (one account_no per row) format, not a 'long' format */

 /********************************************************/
title 'proc transpose approach';
proc sort data=t;
  by account_no;
run;

title2 'intermediate table';
proc transpose data=t out=t1 prefix=NEW_ME_BAL_;
  by account_no;
  id yyyy_mm;
  var mnthend_bal;
run;
proc print data=_LAST_(obs=max) width=minimum; run;

title2 'intermediate table';
proc transpose data=t out=t2 prefix=NEW_CL_BAL_;
  by account_no;
  id yyyy_mm;
  var cred_lim;
run;
proc print data=_LAST_(obs=max) width=minimum; run;

title2 'table';
data t3(drop=_NAME_);
  merge t1 t2;
  by account_no;
run;
proc print data=_LAST_(obs=max) width=minimum; run;
 /********************************************************/


 /********************************************************/
title 'same - using faster self-merge approach';
proc sort data=t;
  by account_no;
run;

data t4(drop=yyyy_mm);
  merge t(where=(yyyy_mm=200505) rename=(mnthend_bal=NEW_ME_BAL_200505 cred_lim=NEW_CL_BAL_200505))
        t(where=(yyyy_mm=200506) rename=(mnthend_bal=NEW_ME_BAL_200506 cred_lim=NEW_CL_BAL_200506))
        ;
  by account_no;
run;
proc print data=_LAST_(obs=max) width=minimum; run;
 /********************************************************/
