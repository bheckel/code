options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: update_obs_in_ds.sas
  *
  *  Summary: Update an observation in an existing dataset.
  *
  * Modified: Fri 03 Jun 2016 14:24:11 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source NOcenter;

data t; do i=1 to 10; foo=5; bar=''; output; end; run;

data t;
  set t;
  if bar eq '' then bar='x';
run;
proc print data=_LAST_(obs=max); run;
