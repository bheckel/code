 /* see also proc_import.sas */

%let DIRROOT = c:\cygwin\home\bheckel\projects\datapost\tmp\VENTOLIN_HFA;
%let CODE = &DIRROOT\CODE;

proc access dbms=xls; * must save the xls as excel 4, 5, 7, or 95;
  create work.acc.access;
  path="&DIRROOT\INPUT_DATA_FILES\RAW MATERIAL & IP DATA\updated_BATCH Production\updated_batchTOstabilityID.xls";
  worksheet="Sheet1";
  skiprows=1;
  type 	1=C 2=C 3=C 4=C 5=C 6=C;
  /* $200 is the max */
  format  1=$8. 2=$8. 3=$200. 4=$8. 5=$8. 6=$1.;
  mixed=yes;
  create work.data.view;
  select all;
  list all;
run;	
proc print data=_LAST_(obs=max) width=minimum; run;
