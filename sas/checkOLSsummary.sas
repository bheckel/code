options NOcenter ls=max ps=max;

%macro ckols(pth, fn);
  libname l "&pth" access=readonly;

  data &fn;
    set l.&fn(obs=max rename=(recorded_text=numres));
    recorded_text = input(numres, ?? F8.);
  run;
/***data _NULL_; set _LAST_(obs=100); put '!!!dbg'(_all_)(=);run;  ***/

  proc sort; by long_product_name long_test_name short_test_name_level1 source; run;

  proc summary data=&fn MISSING;
    class long_product_name long_test_name short_test_name_level1 data_type source;
    output min(recorded_text)=min max(recorded_text)=max mean(recorded_text)=mean;
  run;

  title "&pth/&fn";
/***  proc print data=_LAST_(obs=max where=(_TYPE_ in (0,15))) width=minimum NOobs; run;***/
  proc print data=_LAST_(obs=max where=(_TYPE_ in (0,31))) width=minimum NOobs; run;
%mend;

%ckols(c:/datapost/data/gsk/zebulon/mdi/albuterol, ols_0014t_albuterol);
/***%ckols(z:/datapost/data/gsk/zebulon/mdi/albuterol, ols_0014t_albuterol);***/

/***%ckols(c:/datapost/data/gsk/zebulon/mdpi/advairdiskus, ols_0016t_advairdiskus);***/
/***%ckols(z:/datapost/data/gsk/zebulon/mdpi/advairdiskus, ols_0016t_advairdiskus);***/

/***%ckols(c:/datapost/data/gsk/zebulon/mdpi/sereventdiskus, ols_0017t_sereventdiskus);***/

/***%ckols(x:/datapostdemo/data/gsk/zebulon/soliddose/trizivir, ols_0021t_trizivir);***/
/***%ckols(c:/datapost/data/gsk/zebulon/soliddose/trizivir, ols_0021t_trizivir);***/

/***%ckols(x:/datapostdemo/data/gsk/zebulon/soliddose/valtrex, OLS_0018T_Valtrex);***/
/***%ckols(c:/datapost/data/gsk/zebulon/soliddose/valtrex, OLS_0018T_Valtrex);***/
