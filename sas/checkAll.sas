options NOcenter ls=max ps=max;

%macro checkAll(pth, limst, odse, odst, olst, stream);  /* {{{ */
  libname l "&pth" access=readonly;

  %if &limst ne NA %then %do;
    title "LIMST &pth &limst ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ LIMS TRANSFORM ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~";
    proc print data=l.&limst(obs=max) width=minimum;
    /* PROD_BRAND_NAME,PROD_STRENGTH,material_description,mrp_mat_id,mrp_batch_id,MFG_DT,LAST_GOODS_RECEIPT_DT,sample_status,test_status,long_test_name,short_test_name_level1,
    short_test_name_level2,short_test_name_level3,data_type,trend_flag,recorded_text,test_date,lims_id1,lims_id2,lims_id3,lims_id4,RowIx,RESLOOPIX,RESREPEATIX,RESREPLICATEIX */
      var MRP_BATCH_ID material_description mrp_mat_id long_test_name data_type recorded_text lims_id1 lims_id2 lims_id3 lims_id4 RESLOOPIX RESREPEATIX RESREPLICATEIX;
      where &CRIT1 &CRIT2 &CRIT3 &CRIT4
        ;
    run;
  %end;

  %if &odse ne NA %then %do;
    title "ODSE &pth &odse ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ODS EXTRACT ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~";
    proc sort data=l.&odse out=&odse; by mrp_batch_id mrp_mat_id long_test_name; run;
    proc print data=&odse(obs=max) width=minimum;
      /*var MATERIAL_DESCRIPTION MRP_MAT_ID MRP_BATCH_ID MFG_DT LAST_GOODS_RECEIPT_DT SAMPLE_STATUS TEST_STATUS LONG_TEST_NAME SHORT_TEST_NAME_LEVEL1 SHORT_TEST_NAME_LEVEL2 
          SHORT_TEST_NAME_LEVEL3 DATA_TYPE TEST_INSTANCE REPLICATE_ID RECORDED_TEXT REPORTED_VALUE RECORDED_VALUE TEST_RESULT_UOM TEST_DATE TREND_FLAG INSTRUMENT_ID 
          SAMPLE_DISPOSITION TEST_DISPOSITION RESULT_NUMBER METHOD_ID TEST_ID COMPONENT_ID TEST_RESULT_TYPE TEST_RESULT_DATATYPE PROD_STRENGTH 
          WORK_CNTR_DESC WORK_CNTR_COD*/
      var MRP_BATCH_ID MATERIAL_DESCRIPTION MRP_MAT_ID LONG_TEST_NAME SHORT_TEST_NAME_LEVEL1 SHORT_TEST_NAME_LEVEL2 
          SHORT_TEST_NAME_LEVEL3 DATA_TYPE RECORDED_TEXT
          ;

      where &CRIT1 &CRIT2 &CRIT3 &CRIT4
        ;
    run;
  %end;

  %if &odst ne NA %then %do;
    title "ODST &pth &odst ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ODS TRANSFORM ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~";
    proc sort data=l.&odst out=&odst; by mrp_batch_id mrp_mat_id long_test_name; run;
    proc print data=&odst(obs=max) width=minimum;
    /***var material_description mrp_mat_id mrp_batch_id mfg_dt last_goods_receipt_dt sample_status test_status long_test_name short_test_name_level1 short_test_name_level2 
        short_test_name_level3 data_type test_instance replicate_id recorded_text recorded_value reported_value test_result_uom test_date trend_flag instrument_id 
        sample_disposition test_disposition result_number alt_result_number test_result_datatype METHOD_ID COMPONENT_ID TEST_RESULT_TYPE TEST_ID
        ;***/
      %if &stream eq MDPI %then %do;
        var mrp_batch_id material_description mrp_mat_id fill_material_description fill_batch_number long_test_name short_test_name_level1 short_test_name_level2 short_test_name_level3 data_type recorded_text;
      %end;
      %else %do;
        var mrp_batch_id material_description mrp_mat_id /*fill_material_description fill_batch_number */long_test_name short_test_name_level1 short_test_name_level2 short_test_name_level3 data_type recorded_text;
      %end;

      where &CRIT1 &CRIT2 &CRIT3 &CRIT4
        ;
    run;
  %end;

  %if &olst ne NA %then %do;
    title "OLS &pth &olst ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ SUPER TRANSFORM ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~";
    /* long_product_name,short_product_name_level1,short_product_name_level2,short_product_name_level3,material_description,mrp_mat_id,mrp_batch_id,mfg_dt,last_goods_receipt_dt,
    sample_status,test_status,long_test_name,short_test_name_level1,short_test_name_level2,short_test_name_level3,data_type,test_instance,replicate_id,recorded_text,recorded_value,
    reported_value,test_result_uom,test_date,trend_flag,instrument_id,sample_disposition,test_disposition,result_number,alt_result_number,source*/
    proc print data=l.&olst(obs=max) width=minimum;
      %if &stream eq MDPI %then %do;
        var mrp_batch_id long_product_name material_description long_test_name short_test_name_level1 short_test_name_level2 data_type alt_batch_number replicate_id recorded_text reported_value trend_flag;
      %end;
      %else %do;
        var mrp_batch_id long_product_name material_description long_test_name short_test_name_level1 short_test_name_level2 data_type /*alt_batch_number*/ replicate_id recorded_text reported_value source trend_flag;
      %end;

      where &CRIT1 &CRIT2 &CRIT3 &CRIT4
      ;
    run;
  %end;
%mend;  /* }}} */

%let CRIT1=%str(); %let CRIT2=%str(); %let CRIT3=%str(); %let CRIT4=%str();

/*                                                         LIMST                  ODSE                ODST                   OLS           STREAM   */

/* boronia */
/***%let CRIT1=%str(mrp_batch_id eq: '1ZM0048');***/
/***%let CRIT2=%str(and short_test_name_level1 eq: 'CI');***/
/***%let CRIT3=%str(and data_type eq: 'IND');***/
/***%let CRIT4=%str(and source eq: 'LIMS');***/
/***%checkAll(c:/datapost/data/gsk/zebulon/mdi/albuterol, lims_0020t_albuterol, ods_0304e_albuterol, ods_0002t_albuterol, ols_0014t_albuterol, MDI);***/

/***%let CRIT1=%str(long_test_name eq: 'Cascade');***/
/***%let CRIT1=%str(mrp_batch_id eq: '1ZP9537');***/
/***%let CRIT1=%str(mrp_batch_id eq: '1ZP0983');***/
/***%let CRIT1=%str(mrp_batch_id eq: '1ZP0029');***/
/***%let CRIT1=%str(mrp_batch_id eq: '0ZP2570');***/
/***%checkAll(x:/datapostdemo/data/gsk/zebulon/mdpi/advairdiskus,        NA,       ods_0302e_advairdiskus, ods_0001t_advairdiskus, ols_0016t_advairdiskus, MDPI);***/
/***%checkAll(c:/datapost/data/gsk/zebulon/mdpi/advairdiskus,        NA,       ods_0302e_advairdiskus, ods_0001t_advairdiskus, xwedols_0016t_advairdiskus, MDPI);***/

/***%let CRIT1=%str(mrp_batch_id eq: '1ZP0589');***/
/***%let CRIT1=%str(mrp_batch_id eq: '1ZP8755');***/
%let CRIT1=%str(mrp_batch_id eq: '0ZM4590');
/***%checkAll(x:/datapostdemo/data/gsk/zebulon/mdpi/sereventdiskus,        NA,       ods_0303e_sereventdiskus, ods_0004t_sereventdiskus, ols_0017t_sereventdiskus, MDPI);***/
%checkAll(c:/datapost/data/gsk/zebulon/mdpi/sereventdiskus,        NA,       ods_0303e_sereventdiskus, ods_0004t_sereventdiskus, ols_0017t_sereventdiskus, MDPI);

/***%let CRIT1=%str(mrp_batch_id eq: '9ZM2907');***/
/***%checkAll(x:/datapostdemo/data/gsk/zebulon/soliddose/bupropion,  LIMS_0008T_Bupropion,     ODS_0121E_SD,           NA,         OLS_0002T_Bupropion,   SD);***/

/***%let CRIT1=%str(mrp_batch_id eq: '9ZM2907');***/
/***%checkAll(x:/datapostdemo/data/gsk/zebulon/soliddose/zantac,  lims_0023T_Zantac,     ods_0129e_sd,           NA,        ols_0022t_zantac, SD);***/

/***%let CRIT1=%str(mrp_batch_id eq: '9ZM9345');***/
/***%let CRIT1=%str(mrp_batch_id eq: '0ZM0167');***/
/***%checkAll(x:/datapostdemo/data/gsk/zebulon/soliddose/valtrex,  LIMS_0004T_Valtrex,     ODS_0103E_SD,           NA,        OLS_0018T_Valtrex, SD);***/

/***%let CRIT1=%str(mrp_batch_id in ('0ZM0063','0ZM5214'));***/
/***%checkAll(x:/datapostdemo/data/gsk/zebulon/soliddose/trizivir,  LIMS_0015T_Trizivir,     ODS_0116E_SD,           NA,        OLS_0021T_Trizivir, SD);***/
/***%checkAll(c:/datapost/data/gsk/zebulon/soliddose/trizivir,  LIMS_0015T_Trizivir,     ODS_0116E_SD,           NA,        OLS_0021T_Trizivir, SD);***/

/***%let CRIT1=%str(mrp_batch_id eq: '9ZM2907');***/
/***%checkAll(x:/datapostdemo/data/gsk/zebulon/soliddose/retrovir,  LIMS_0014T_Retrovir,     ODS_0113E_SD,           NA,        OLS_0020T_Retrovir, SD);***/

/***%let CRIT1=%str(mrp_batch_id eq: '0ZM1022');***/
/***%checkAll(c:/datapost/data/gsk/zebulon/soliddose/valtrex,  LIMS_0004T_Valtrex,     ODS_0103E_SD,           NA,        OLS_0018T_Valtrex, SD);***/
