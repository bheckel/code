options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: clipboard.excel.sas
  *
  *  Summary: Put clipboarded Excel data directly into a dataset.
  *
  *  Adapted: Wed 16 Jul 2008 12:32:02 (Bob Heckel -- Phil Mason email tip)
  *---------------------------------------------------------------------------
  */
options source NOcenter;

 /* Before executing:
  *   Within Excel, highlight and copy your selection range
  */

filename ft44f001 dde 'clipboard' notab lrecl=32768;
filename ft45f001 temp;

 /* Find the last column number of the selection */
proc printto log=ft45f001; run;
data _null_;
  infile ft44f001;
run;
proc printto; run;

data _null_;
  length session $128;
  infile ft45f001 dlm=' ,' dsd;
  input @;
  put _all_;  /* debug */
  if index(_infile_, 'SESSION=') then do;
    input @'SESSION=' session;
    lastcolumn='col' || scan(session,-1,'C');
    call symput('last_column', lastcolumn);
    firstcolumn='col' || substr(scan(session,-2,"C"),1, index(scan(session,-2,"C"),":")-1);
    call symput('first_column', firstcolumn);
    stop;
  end;
run;

 /* Input the desired data */
data want;
  infile ft44f001 dlm='09'x dsd missover;
  /* Set informats as needed */
  informat &first_column.-&last_column. $5.;
  input &first_column.-&last_column.;
run; 
proc print data=_LAST_(obs=max) width=minimum; run;
