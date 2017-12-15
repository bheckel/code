%macro build_lims_mapping_ds;
  options ls=max ps=max;
   /* 
    * 1-update CCF field below (to keep track of limsmap versions only, not used by code)
    *
    * 2-run this
    *
    * 3-after an optional diff, copy the resulting .sas7bdat to dev's DataPost\data\GSK\Metadata\Reference\LIMS\
    *
    */
   
  /* EDIT */
  /* EDIT */
  /* EDIT */
  %let LASTMODCCF=97925;
  /* EDIT */
  /* EDIT */
  /* EDIT */

  libname DEMOLIMS 'X:\DataPostDEMO\data\GSK\Metadata\Reference\LIMS';
  libname PRODLIMS 'Z:\DataPost\data\GSK\Metadata\Reference\LIMS' access=READONLY;

  filename MDES '\\Bredsntp002\uk_gms_wre_data_area\GDM Reporting Profiles\DATAPOST\Verified\ZEB_LIMS_REPORTING_PROFILE.csv';

   /* Before we start, make sure we know what changed from the last run for (optional) diff */
  ods LISTING close; ods CSV file='_prevDEMOlims_report_profile.csv'; proc print data=DEMOLIMS.lims_report_profile(drop=lastmodccf);run; ods CSV close;

  data mdes;
    infile MDES delimiter=',' MISSOVER LRECL=32767 DSD firstobs=2;

    input lims_id1 :$80.
          lims_id2 :$80.
          lims_id3 :$80.
          lims_id4 :$80.
          long_test_name :$80.
          short_test_name_level1 :$80.
          short_test_name_level2 :$80.
          short_test_name_level3 :$80.
          data_type :$80.
          trend_flag :$80.
          ;
  run;

  data mdes;
    set mdes;

    lims_id_key = trim(left(lims_id1)) || '|' || trim(left(lims_id2)) || '|' || trim(left(lims_id3)) || '|' || trim(left(lims_id4));
    if lims_id1 ne '';

    lastmodccf="&LASTMODCCF";
  run;

  data DEMOLIMS.lims_report_profile;
     set mdes end=e;

     output;

    /* Fix albuterol leakman */
    if e then do;
       lims_id1 = 'AM0952- Manual Leak Test';
       lims_id2 = 'CALCDATATBL-LEAKAGE';
       lims_id3 = '112.';
       lims_id4 = '';
       long_test_name = 'Leak Rate (mg/year)';
       short_test_name_level1 = 'Leak Rate (mg/year)';
       short_test_name_level2 = '';
       short_test_name_level3 = '';
       data_type = 'INDIVIDUAL';
       trend_flag = 'Y';
       lims_id_key = 'AM0952- Manual Leak Test|CALCDATATBL-LEAKAGE|112.|';
       output;
       lims_id1 = 'AM0952- Manual Leak Test';
       lims_id2 = 'CALCDATATBL-PCTLEAKAGE';
       lims_id3 = '112.';
       lims_id4 = '';
       long_test_name = 'Leak Rate (%/year)';
       short_test_name_level1 = 'Leak Rate (%/year)';
       short_test_name_level2 = '';
       short_test_name_level3 = '';
       data_type = 'INDIVIDUAL';
       trend_flag = 'Y';
       lims_id_key = 'AM0952- Manual Leak Test|CALCDATATBL-PCTLEAKAGE|112.|';
       output;
    end;
  run;

   /* There should not be dups but input file is maintained by userland... */
  proc sort NOdupkey; by lims_id1 lims_id2 lims_id3 lims_id4; run;

   /* Debugging */
/***  proc contents; run;***/
   /* To allow a diff of what changed (if desired) */
  ods CSV file='_newDEMOlims_report_profile.csv'; proc print data=DEMOLIMS.lims_report_profile(drop=lastmodccf);run; ods CSV close;
  ods CSV file='_currPRODlims_report_profile.csv'; proc print data=PRODLIMS.lims_report_profile(drop=lastmodccf);run; ods CSV close;
%mend build_lims_mapping_ds;
%build_lims_mapping_ds;
