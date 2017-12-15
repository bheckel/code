
libname oldlib '/Drugs/FunctionalData' access=readonly;
libname newlib '/Drugs/Personnel/bob/PQA_NDC_merge/tmp' access=readonly;


proc contents data=oldlib.pqa_medlist out=old NOprint; run;
proc contents data=newlib.pqa_medlist out=new NOprint; run;


title 'on old not on new';
proc sql;
  select upcase(name) from old
  EXCEPT
  select upcase(name) from new
  ;
quit;

title 'on new not on old';
proc sql;
  select upcase(name) from new
  EXCEPT
  select upcase(name) from old
  ;
quit;
