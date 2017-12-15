options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: check_all_ds.lims.sas
  *
  *  Summary: Quick check methods of lims DP datasets
  *
  *  Created: Thu 24 Jan 2013 10:16:01 (Bob Heckel)
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
    select distinct specname, dispname
    from &env..&ds
    order by specname
    ;
  quit;

  proc print data=_LAST_(obs=max) width=minimum; run;
%mend;
%m(prd, lims_0001e_avandametsum);
%m(prd, lims_0003e_avandametind);
%m(prd, lims_0005e_avandarylsum);
%m(prd, lims_0007e_avandarylind);
%m(prd, lims_0009e_rosiglitazonesum);
%m(prd, lims_0011e_rosiglitazoneind);
%m(prd, lims_0017e_lamictalsum);
%m(prd, lims_0019e_lamictalind);
/***%m(prd, lims_0037e_albuterolsum);***/
/***%m(prd, lims_0039e_albuterolind);***/
%m(prd, lims_0041e_lovazasum);
%m(prd, lims_0043e_lovazaind);
%m(prd, lims_0045e_lotronexsum);
%m(prd, lims_0047e_lotronexind);
%m(prd, lims_0053e_valtrexsum);
%m(prd, lims_0055e_valtrexind);
%m(prd, lims_0057e_wellbutrinsum);
%m(prd, lims_0059e_wellbutrinind);
%m(prd, lims_0061e_retrovirsum);
%m(prd, lims_0063e_retrovirind);
%m(prd, lims_0065e_trizivirsum);
%m(prd, lims_0067e_trizivirind);
%m(prd, lims_0069e_zofransum);
%m(prd, lims_0071e_zofranind);
%m(prd, lims_0073e_bupropionsum);
%m(prd, lims_0075e_bupropionind);
%m(prd, lims_0085e_zybansum);
%m(prd, lims_0087e_zybanind);
%m(prd, lims_0089e_zoviraxsum);
%m(prd, lims_0091e_zoviraxind);
%m(prd, lims_0093e_zantacsum);
%m(prd, lims_0095e_zantacind);
%m(prd, lims_0101e_ratio_lamotriginesum);
%m(prd, lims_0103e_ratio_lamotrigineind);
