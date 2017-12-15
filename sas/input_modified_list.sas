
data t;
  infile cards;
  /* Formatted input won't read the oatmeal line correctly, thinking it needs to go 14 chars */
  ***input flavor $14. qty :COMMA.;
  /*          list modifiers        */
  /*           _         _          */
  input flavor &$14. qty :COMMA.;
  /* This free-form data must be delimited by 2+ spaces for "&"! */
  cards;
chocolate chip  10,465
oatmeal  12,187
peanut butter  12,333
  ;
run;
proc print data=_LAST_(obs=max) width=minimum; run;
proc contents; run;

