
%macro ck(pth, fn);
  libname l "&pth" access=readonly;

  data &fn;
    set l.&fn(rename=(recorded_text=nresult));
    if mrp_batch_id in('0ZM2413','5ZM0092');
    recorded_text = input(nresult, ?? F8.);
  run;
/***data _NULL_; set _LAST_(obs=100); put '!!!dbg'(_all_)(=);run;  ***/

  proc sort; by mrp_batch_id method_description test_id ; run;

  proc summary data=&fn MISSING;
    class mrp_batch_id method_description test_id;
    output min(recorded_text)=min max(recorded_text)=max mean(recorded_text)=mean;
  run;

  title "&pth/&fn";
/***  proc print data=_LAST_ width=minimum NOobs; run;***/
/***  proc print data=_LAST_(obs=max where=(_TYPE_ in (0,31))) width=minimum NOobs; run;***/
/***  proc print data=_LAST_(obs=max where=(_TYPE_ in (0,15))) width=minimum NOobs; run;***/
  proc print data=_LAST_(obs=max) width=minimum NOobs; run;
%mend;

/***%ckods(x:/datapostarchive/valtrex_caplets/output_compiled_data, pull_lift);***/
/***%ck(x:/datapostarchive/valtrex_caplets/output_compiled_data, pull_liftOLD);***/


%macro ck2(pth, fn);
  libname l "&pth" access=readonly;

  data &fn;
    set l.&fn;
    if mrp_batch_id in('1ZP7268');
  run;

  proc sort; by mrp_batch_id ; run;

  proc freq data=&fn;
    tables mrp_batch_id;
  run;

  title "&pth/&fn";
/***  proc print data=_LAST_ width=minimum NOobs; run;***/
/***  proc print data=_LAST_(obs=max where=(_TYPE_ in (0,31))) width=minimum NOobs; run;***/
/***  proc print data=_LAST_(obs=max where=(_TYPE_ in (0,15))) width=minimum NOobs; run;***/
  proc print data=_LAST_(obs=max) width=minimum NOobs; run;
%mend;

/***%ck2(c:/datapost/data/gsk/zebulon/mdpi/advairdiskus, ols_0016t_advairdiskus);***/
%ck2(z:/datapost/data/gsk/zebulon/mdpi/advairdiskus, ols_0016t_advairdiskus);
