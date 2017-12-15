options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: print_last_10_obs.sas
  *
  *  Summary: Efficiently process only the last 10 obs in a ds
  *
  *           See also obs_count.mcr.sas
  *
  *  Created: Mon 29 Jul 2013 12:55:51 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source NOcenter dsoptions=note2err;

data t;
  do p=o-9 to o;
    set sashelp.shoes point=p nobs=o;
    output t;
  end;
  stop;
run;
proc print data=_LAST_(obs=max) width=minimum; run;
