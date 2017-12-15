
data t;
  infile '/Drugs/TMMEligibility/DHDrugPari/Imports/20170729/Output/CLI_1205874872_TMM_candidates_fdw.csv' dlm='|';
  input aid :$20. clid $ nrx $ dt $10.;
run;
title "&SYSDSN";proc print data=_LAST_(obs=10) width=minimum heading=H;run;title;

proc sort NOdupkey; by aid; run;

proc export outfile='/Drugs/TMMEligibility/DHDrugPari/Imports/20170729/Output/CLI_1205874872_TMM_candidates_fdw.csv2' data=t dbms=dlm replace;
  delimiter='|';
  putnames=no;
run;
