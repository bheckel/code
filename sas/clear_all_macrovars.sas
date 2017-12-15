
%macro m;
  %local bar;
  %let v1=foo;
  %global v2;
  %let v2=bar;

  /* Clear all global mvars */
  proc sql noprint;
    select '%let '||compress(name)||' =;' into : RESETMVARS separated by ' '
    from DICTIONARY.macros
    where scope='GLOBAL'
    ;
  quit;
  &RESETMVARS;
  %put !!!&v1;
  %put !!!&v2;
%mend;
%m;
