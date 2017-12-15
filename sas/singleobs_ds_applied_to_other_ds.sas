options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: singleobs_ds_applied_to_other_ds.sas
  *
  *  Summary: Merging a Single Observation with All Observations
  *
  *  Created: Fri 30 May 2008 11:35:30 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source NOcenter;

data singleobs;
  input tot;
  cards;
42
  ;
run;

data totsales;
  input a $ b $ c $;
  cards;
foo bar baz
foo2 bar2 baz2
foo3 bar3 baz3
  ;
run;

data national;
  if _N_=1 then set singleobs;
  set totsales;
run;
proc print data=_LAST_(obs=max) width=minimum; run;
