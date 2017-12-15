options NOreplace;

 /* Make quick backup */

%let plan=va;
%let svr=01;

 /* Copy plan's recs to a local temp area as backup before running providers */

libname LOC 'd:\temp';
libname BPMS oledb provider=sqloledb.1 
        properties=("Persist Security Info"=True "Integrated Security"=SSPI 
        "Data Source"="wnetbpms1\production"
        "Initial Catalog"="BPMS") schema=dbo ignore_read_only_columns=yes
        access=readonly
        ;
libname PLAN oledb provider=sqloledb.1 
        properties=("Persist Security Info"=True "Integrated Security"=SSPI 
        "Data Source"="w23psql&svr.\production"
        "Initial Catalog"="bpms_&plan") schema=dbo ignore_read_only_columns=yes
        access=readonly
        ;

data LOC.tref&SYSDATE;
  set BPMS.t_ref_bpms_prescriber_info;
run;

endsas;
data LOC.&plan.clp&SYSDATE;
  set PLAN.claims_pharmacy;
  if sourcefile ='CLM_VA0506.TXT';
run;
