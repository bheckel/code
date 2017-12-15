/* Edits */
/* 1. cp -i /Drugs/FunctionalData/tmm_targeted_list_refresh.sas7bdat ~/bob/tmp/tmm_targeted_list_refresh.`date +\%d\%b\%y`.sas7bdat */
/* 2. */

 /* DELETE OBS */
data tmm_targeted_list_refresh;
  set tmm_targeted_list_refresh;
  if clid in(675) then delete;
run;
title "after";proc print data=_last_ width=minimum heading=H noobs; run;title;

/* ADD VAR */
data tmm_targeted_list_refresh;
  retain clid long_client_name projected_build_date lastbuild_date refresh_cycle_days import_delay_days on_hold lastimport_date short_name is_independent
         is_redpoint months mindrugs cap numcap rm_enrolled atebpatientid minage job_type nrx el_file;
  length job_type $80;
  set tmm_targeted_list_refresh;
  job_type='Imports';
  nrx='';
run;
title "after";proc print data=_last_(obs=15) width=minimum heading=H noobs; run;title;

/* MODIFY */
%let clids=1003,400;
title "before";proc print data=FUNCDATA.tmm_targeted_list_refresh width=minimum heading=H noobs; where clid in(&clids); run;title;
data tmm_targeted_list_refresh;
  set tmm_targeted_list_refresh;
  if clid in(&clids) then do;
    el_file='';
    output;
  end;
  else do;
    output;
  end;
run;
title "after";proc print data=_last_ width=minimum heading=H noobs; where clid in(&clids); run;title;

proc contents;run;
