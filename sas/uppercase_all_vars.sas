%macro m;
proc sql PRINT;
  select nvar into :NUM_VARS
  from dictionary.tables
  where libname='WORK' and memname='ALL_METHS_INDIVIDUALS'
  ;
  select distinct(name) into :VAR1-:VAR%TRIM(%LEFT(&NUM_VARS))
  from dictionary.columns
  where libname='WORK' and memname='ALL_METHS_INDIVIDUALS'
  ;
quit;

proc datasets library=WORK;
  modify all_meths_individuals;
  rename %do i=1 %to &NUM_VARS;
           &&VAR&i=%upcase(&&VAR&i.)
         %end;
         ;
run;
%mend;
%m;
