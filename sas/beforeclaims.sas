options NOreplace sgen;


 /* Copy recs to a local temp area as backup before running claims */

libname LOC 'd:/temp';
%let plan=%upcase(wi);
%let svrnum=01;

 /* 2005-08-11 NOT SURE THIS IS NECESARY ANY LONGER */
 /* 2005-08-11 NOT SURE THIS IS NECESARY ANY LONGER */
 /* 2005-08-11 NOT SURE THIS IS NECESARY ANY LONGER */
 /***
libname PLANSVR oledb provider=sqloledb.1 
        properties=("Persist Security Info"=True "Integrated Security"=SSPI 
        "Data Source"="W23PSQL&svrnum\production"
        "Initial Catalog"="BPMS_&plan") schema=dbo ignore_read_only_columns=yes;  

data LOC.&plan.claims_pharm&SYSDATE;
  set PLANSVR.claims_pharmacy;
run;
 ***/

libname BPMS oledb provider=sqloledb.1 
        properties=("Persist Security Info"=True "Integrated Security"=SSPI 
        "Data Source"="WNETBPMS1\production"
        "Initial Catalog"="BPMS") schema=dbo ignore_read_only_columns=yes;  

 /* Not plan-specific but keeps from overwriting if run 2x in a day */
data LOC.&plan.lu_ndc_list&SYSDATE;
  set BPMS.lu_ndc_list;
run;
