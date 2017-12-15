options NOreplace fullstimer;

 /* EDIT */
%let plan=de;


 /* Copy plan's recs to a local temp area as backup before running providers */

libname LOC 'd:\temp';
libname BPMS oledb provider=sqloledb.1 
        properties=("Persist Security Info"=True "Integrated Security"=SSPI 
        "Data Source"="wnetbpms1\production"
        "Initial Catalog"="BPMS") schema=dbo ignore_read_only_columns=yes
        access=readonly
        ;

data LOC.&plan.providers&SYSDATE;
  set BPMS.t_ref_bpms_prescriber_info;
  if plancode eq "&plan";
run;
