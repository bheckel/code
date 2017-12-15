
 /* Optionally run prior to running build_lims_mapping_ds.sas to verify
  * contents of the 3 environments, only writes temporary CSVs 
  * 12-Nov-12 rsh86800
  */

%macro check_lims_mapping_ds;
  options ls=max ps=max;

  /*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
  libname PROD 'Z:\DataPost\data\GSK\Metadata\Reference\LIMS' access=readonly;
  data prodWithoutCCFnum;
    set PROD.lims_report_profile(drop=lastmodccf);
  run;
  proc export data=prodWithoutCCFnum OUTFILE='TMPcurrPRODlims_report_profile.csv' DBMS=CSV REPLACE; run;
  /*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

  /*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
  libname DEMO 'X:\DataPostDEMO\data\GSK\Metadata\Reference\LIMS' access=readonly;
  data demoWithoutCCFnum;
    set DEMO.lims_report_profile(drop=lastmodccf);
  run;
  proc export data=demoWithoutCCFnum OUTFILE='TMPcurrDEMOlims_report_profile.csv' DBMS=CSV REPLACE; run;
  /*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

  /*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
  filename MDES '\\Bredsntp002\uk_gms_wre_data_area\GDM Reporting Profiles\DATAPOST\Verified\ZEB_LIMS_REPORTING_PROFILE.csv';
  data csv;
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

  data csv;
    set csv;

    lims_id_key = trim(left(lims_id1)) || '|' || trim(left(lims_id2)) || '|' || trim(left(lims_id3)) || '|' || trim(left(lims_id4));
    if lims_id1 ne '';
  run;

  data csv;
     set csv end=e;

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

   /* There should not be dups but file is maintained by userland... */
  proc sort NOdupkey; by lims_id1 lims_id2 lims_id3 lims_id4; run;

  proc export data=csv OUTFILE='TMPcurrMDESlims_report_profile.csv' DBMS=CSV REPLACE; run;
  /*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
%mend check_lims_mapping_ds;
%check_lims_mapping_ds;
