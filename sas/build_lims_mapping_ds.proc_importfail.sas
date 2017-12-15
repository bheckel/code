options ls=max ps=max;
 /* Download from Teamsite then save xlsx as v95 Excel 
  * Assumes the new output ds will be copied to 
  * \datapost\data\GSK\Metadata\Reference\LIMS
  */
libname l '.';
libname demo 'X:\DataPostDEMO\data\GSK\Metadata\Reference\LIMS';

proc import datafile="LIMS_REPORT_PROFILE.xls" 
            out=lims_report_profile;
  sheet='Sheet1';
run;
 /* Occasionally userland will have hidden fields in the xls so drop F: */
data l.lims_report_profile(drop=/*prod_brand_name*/ F:);
  set lims_report_profile;
  lims_id_key = trim(left(lims_id1)) || '|' || trim(left(lims_id2)) || '|' || trim(left(lims_id3)) || '|' || trim(left(lims_id4));
  if lims_id1 ne '';
run;
proc contents; run;
/***proc print data=_LAST_(obs=max); run;***/
proc export data=l.lims_report_profile OUTFILE='TMPlims_report_profile.csv' DBMS=CSV REPLACE; run;
proc export data=demo.lims_report_profile OUTFILE='TMPdemolims_report_profile.csv' DBMS=CSV REPLACE; run;


endsas;
vi -d TMP*
cp lims_report_profile.sas7bdat /cygdrive/c/datapost/data/GSK/Metadata/Reference/LIMS/ && cp -i lims_report_profile.sas7bdat /cygdrive/x/datapostDEMO/data/GSK/Metadata/Reference/LIMS/
