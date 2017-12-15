options mlogic mprint symbolgen noovp fmtsearch=(work fmtlib)
        nosortdevwarn nocenter missing=0 nos99nomig
        ;

***libname L "/u/dwj2/mvds/NAT/2004";
libname L "/u/dwj2/mvds/FET/2004";
***libname L "/u/dwj2/mvds/MOR/2004";
***libname FMTLIB "DWJ2.NAT2003R.FMTLIB" DISP=SHR WAIT=250;
libname FMTLIB "DWJ2.FET2003R.FMTLIB" DISP=SHR WAIT=250;
***libname FMTLIB "DWJ2.MOR2003R.FMTLIB" DISP=SHR WAIT=250;

proc format library=FMTLIB cntlout=lista;
  select $LISTA;
run;

proc sql noprint;
  select start into :V separated by '","'
  from lista
  ;
quit;

%let V=%quote(")&V%quote(");
proc sql;
  select label from dictionary.columns
  where libname eq 'L' and memname eq 'IDNEW' and name in(&V)
  ;
quit;
