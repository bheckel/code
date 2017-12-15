
proc sql noprint;
  select strip(put(length,8.)) into :_PRESC_VLEN
  from dictionary.columns
  where upcase(libname) eq 'WORK' and
        upcase(memname) eq 'GOODCLM' and
        upcase(memtype) eq 'DATA'
        upcase(name) = 'PRESCRIBER_ID' 
        ;
quit;

data foo;
  length CompareDoc $ &_PRESC_VLEN.;
  /* ... */
run;
