
data t;
  ***infile cards DLM='09'x DSD;  /* tab delimited */
  /* Space is default but listed here for clarity */
  infile cards DLM=', *|' DSD;
  input (a1-a5) ($);
  cards;
1,2,3|4 5
1 2,"3",4*5
1 2,3,4*5
  ;
run;
proc print data=_LAST_(obs=max) width=minimum; run;
