options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: force_single_obs_dataset.sas
  *
  *  Summary: Check for zero observations, insert a blank row of data.
  *
  *  Created: Wed 07 Jan 2004 11:19:52 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source;

data emptyds;
  input density  crimerate  state $ 14-27  stabbrev $ 29-30;
  cards;
  ;
run;

data forceobs;
  set emptyds point=place nobs=hellowisconsin;
  if hellowisconsin eq 0 then
    do;
      density=111;
      output;
      stop;
    end;
run;

title "&SYSDSN"; proc print; run; title;
