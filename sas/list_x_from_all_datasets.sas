options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: u:/gsk/list_x_from_all_datasets.sas
  *
  *  Summary: Look at certain vars across several OLS
  *
  *  Created: Fri 19 Apr 2013 11:33:07 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source NOcenter dsoptions=note2err ls=max ps=max;

libname demo (
  'x:/DatapostDEMO/data/gsk/zebulon/mdi'
  'x:/DatapostDEMO/data/gsk/zebulon/mdi/advairhfa'
  'x:/DatapostDEMO/data/gsk/zebulon/mdi/albuterol'
  'x:/DatapostDEMO/data/gsk/zebulon/mdpi'
  'x:/DatapostDEMO/data/gsk/zebulon/mdpi/advairdiskus'
  'x:/DatapostDEMO/data/gsk/zebulon/mdpi/sereventdiskus'
  'x:/DatapostDEMO/data/gsk/metadata/reference/gist'
  'x:/DatapostDEMO/data/gsk/sss/mdpi/seretidediskus'
  )
  access=readonly
;

libname tst (
  'y:/Datapost/data/gsk/zebulon/mdi/advairhfa'
  'y:/Datapost/data/gsk/zebulon/mdi/albuterol'
  'y:/Datapost/data/gsk/zebulon/mdpi/advairdiskus'
  'y:/Datapost/data/gsk/zebulon/mdpi/sereventdiskus'
  'y:/Datapost/data/gsk/zebulon/soliddose/avandamet'
  'y:/Datapost/data/gsk/zebulon/soliddose/avandaryl'
  'y:/Datapost/data/gsk/zebulon/soliddose/bupropion'
  'y:/Datapost/data/gsk/zebulon/soliddose/lamictal'
  'y:/Datapost/data/gsk/zebulon/soliddose/lotronex'
  'y:/Datapost/data/gsk/zebulon/soliddose/lovaza'
  'y:/Datapost/data/gsk/zebulon/soliddose/methylcellulose'
  'y:/Datapost/data/gsk/zebulon/soliddose/ratiolamotrigine'
  'y:/Datapost/data/gsk/zebulon/soliddose/retigabine'
  'y:/Datapost/data/gsk/zebulon/soliddose/retrovir'
  'y:/Datapost/data/gsk/zebulon/soliddose/rosiglitazone'
  'y:/Datapost/data/gsk/zebulon/soliddose/trizivir'
  'y:/Datapost/data/gsk/zebulon/soliddose/valtrex'
  'y:/Datapost/data/gsk/zebulon/soliddose/wellbutrin'
  'y:/Datapost/data/gsk/zebulon/soliddose/zantac'
  'y:/Datapost/data/gsk/zebulon/soliddose/zofran'
  'y:/Datapost/data/gsk/zebulon/soliddose/zovirax'
  'y:/Datapost/data/gsk/zebulon/soliddose/zyban'
  'y:/Datapost/data/gsk/zebulon/soliddose'
  'y:/Datapost/data/gsk/zebulon/mdi'
  'y:/Datapost/data/gsk/metadata/reference/merps'
  )
  access=readonly
;

libname prd (
  'z:/Datapost/data/gsk/zebulon/mdi/advairhfa'
  'z:/Datapost/data/gsk/zebulon/mdi/albuterol'
  'z:/Datapost/data/gsk/zebulon/mdpi/advairdiskus'
  'z:/Datapost/data/gsk/zebulon/mdpi/sereventdiskus'
  'z:/Datapost/data/gsk/zebulon/soliddose/avandamet'
  'z:/Datapost/data/gsk/zebulon/soliddose/avandaryl'
  'z:/Datapost/data/gsk/zebulon/soliddose/bupropion'
  'z:/Datapost/data/gsk/zebulon/soliddose/lamictal'
  'z:/Datapost/data/gsk/zebulon/soliddose/lotronex'
  'z:/Datapost/data/gsk/zebulon/soliddose/lovaza'
  'z:/Datapost/data/gsk/zebulon/soliddose/methylcellulose'
  'z:/Datapost/data/gsk/zebulon/soliddose/ratiolamotrigine'
  'z:/Datapost/data/gsk/zebulon/soliddose/retigabine'
  'z:/Datapost/data/gsk/zebulon/soliddose/retrovir'
  'z:/Datapost/data/gsk/zebulon/soliddose/rosiglitazone'
  'z:/Datapost/data/gsk/zebulon/soliddose/trizivir'
  'z:/Datapost/data/gsk/zebulon/soliddose/valtrex'
  'z:/Datapost/data/gsk/zebulon/soliddose/wellbutrin'
  'z:/Datapost/data/gsk/zebulon/soliddose/zantac'
  'z:/Datapost/data/gsk/zebulon/soliddose/zofran'
  'z:/Datapost/data/gsk/zebulon/soliddose/zovirax'
  'z:/Datapost/data/gsk/zebulon/soliddose/zyban'
  'z:/Datapost/data/gsk/zebulon/soliddose'
  'z:/Datapost/data/gsk/zebulon/mdi'
  'z:/Datapost/data/gsk/metadata/reference/merps'
  )
  access=readonly
;

%macro m(env, ds);
  /* Use this instead of TITLE to avoid missing the already past-the-window products */
  data _null_;
    file PRINT;
    put "~~~~~~~~~~~running &ds";
    put '';
  run;

  proc sql NOprint;
    create table t2 as
    select distinct long_test_name, short_test_name_level1, short_test_name_level2, long_product_name, source
    from &env..&ds
    order by long_test_name, source, long_product_name
    ;
  quit;

  proc print data=_LAST_(obs=max) width=minimum NOobs; run;
%mend;

*%m(prd, ols_0011t_methylcellulose);
*%m(prd, ols_0006t_lamictal);
*%m(prd, ols_0002t_bupropion);
*%m(prd, ols_0003t_wellbutrin);
*%m(prd, ols_0005t_zyban);
*%m(prd, ols_0007t_lovaza);
*%m(prd, ols_0011t_methylcellulose);
*%m(prd, ols_0008t_zofran);
*%m(prd, ols_0010t_zovirax);
*%m(prd, ols_0012t_retigabine);
*%m(prd, ols_0009t_lotronex);
%m(prd, ols_0023t_avandamet);
%m(prd, ols_0024t_avandaryl);
%m(prd, ols_0025t_rosiglitazone);
*%m(prd, ols_0027t_ratio_lamotrigine);
*%m(prd, ols_0021t_trizivir);
*%m(prd, ols_0020t_retrovir);
*%m(prd, ols_0018t_valtrex);
*%m(prd, ols_0022t_zantac);

*%m(prd, ols_0014t_albuterol);
*%m(prd, ols_0004t_advairhfa);
*%m(prd, ols_0016t_advairdiskus);
*%m(prd, ols_0017t_sereventdiskus);
