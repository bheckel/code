options FMTSEARCH=(FMTLIB) nocenter mlogic mprint sgen;

libname L '/u/dwj2/mvds/NAT/2004';  /* open yrs only!! */
libname FMTLIB 'DWJ2.NAT2003.FMTLIB' DISP=SHR WAIT=250;

proc format library=FMTLIB cntlout=lista;
  select $LISTA;
run;

proc sql NOPRINT;
  select cats(start,label) into :FMTS separated by ' '
  from lista
  where start eq 'MENSEYR'
  ;
quit;

data nat;
  set L.akold;
  format &fmts;
run;

proc freq; 
  table menseyr;
run;
