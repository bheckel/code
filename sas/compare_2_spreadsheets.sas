options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: compare_2_spreadsheets.sas
  *
  *  Summary: Turn spreadsheets into datasets then see what is on one but not
  *           the other
  *
  *  Created: Fri 06 Dec 2013 11:18:25 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source NOcenter dsoptions=note2err;

libname l '.';

proc import datafile='OLS_0016T_AdvrDisk.xlsx' out=l.tmp dbms=XLSX;
  getnames=yes;
  mixed=yes;
run;
proc import datafile='OLS_0016T_AdvrDiskNEW.xlsx' out=l.tmp2 dbms=XLSX;
  getnames=yes;
  mixed=yes;
run;

title 'in old, not in new';
proc sql;
  select * from l.tmp
  EXCEPT
  select * from l.tmp2
  ;
quit;

title 'in new, not in old';
proc sql;
  select * from l.tmp2
  EXCEPT
  select * from l.tmp
  ;
quit;

