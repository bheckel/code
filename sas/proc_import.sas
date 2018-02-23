options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: proc_import.sas
  *
  *  Summary: Read Excel spreadsheet's worksheet directly into PC SAS.
  *
  *           Requires ---SAS/ACCESS Interface to PC Files
  *
  *  Created: Mon 09 Jun 2003 12:53:56 (Bob Heckel)
  * Modified: Mon 05 Feb 2018 14:47:22 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source;

 /* Excel is forcing to numeric but we want char so we resort to tricks */
proc import datafile='/Drugs/Cron/Daily/HarpsPriorityTasks/patients_to_target.xlsx' out=targets(rename=(a=pharmacypatientid)) dbms=xlsx;
  getnames=no;
run;
data targets;
  set targets(firstobs=2);
run;
proc contents;run;



 /* v9.4 */
proc import datafile='~/code/sas/Book1.xlsx' out=work.tmp dbms=XLSX REPLACE;
  getnames=yes;
  sheet='Sheet 2';
run;
title "&SYSDSN";proc print data=_LAST_ width=minimum heading=H;run;title;



 /* v9+ */
/***proc import datafile='JurongReports_SXReport.xls' out=work.tmp dbms=XLS;***/
proc import datafile='JurongReports_SXReport.xlsx' out=work.tmp dbms=XLSX REPLACE;
  getnames=yes;
  mixed=yes;
run;
 /* tmp.sas7bdat has mrp_mat_id as BEST12. which is too small (get 1E13) so do 
    this to view w/o exponentiation:
      proc sql;
        select distinct mrp_mat_id format=BEST16.
        from tmp1.tmp2;
      quit;
  */


endsas;
 /* Parse DIR command output into a dataset */
 /* c:\> C:\cygwin\home\bheckel\code\sas>dir >junk.txt */
proc import datafile='junk.txt' out=foo dbms=dlm;
  delimiter='00'x;
  getnames=no;
  datarow=8;  /* skip headers */
run;
proc print data=_LAST_(obs=max); run;



endsas;
 /* Excel all fields */
proc import datafile="d:\temp\sumspd.xls" 
            out=foo;
  sheet='All Ages';
  ***getnames=yes;  /* if name has a space, it is replace by underscore */
run;
proc print data=_LAST_(obs=max); run;


 /* MS Access */
proc import out=work.tmp datatable=CLM_UT0506 DBMS=ACCESS2000;
  database="d:/temp/CLM_UT0506.mdb";
run;

 /* Don't know of a way to only IMPORT specific vars so do this */
data tmp;
  set tmp(keep=ndc);
run;

proc print data=_LAST_(obs=10); run;


 /* This undocumented range "feature" may be required for worksheets with
  * spaces in name
  */
proc import datafile='c:\temp\RePopulate_DATALOAD.xls' out=work.tmp dbms=EXCEL2000;
  range='Advair HFA$';
  getnames=yes;
run;



proc import datafile='c:/temp/junk.xls' out=tmp dbms=EXCEL2000 /*replace*/;
  getnames=no;  /* use F1, F2... */
  sheet="SAPList";
  /* TODO why is this a syntax error? */
  /***  datarow=2;***/
run;

data tmp(drop=d1-d3);
  set tmp(firstobs=3);

  /* Convert string 30.11.2006 to date */
  d1=scan(f4,1);
  d2=scan(f4,2);
  d3=scan(f4,3);
  dt=mdy(d2,d1,d3);

  put _all_;
run;

proc contents; run;
proc print data=_LAST_; format dt date7.; run;

endsas;
0446009	6ZP2866	ZOFRAN TAB 4MG 30S	27.03.2006	02.08.2010	FIXD
0561002	4ZP0998	AMERGE TAB 1.0MG 9 S BLISTER	16.01.2005	30.11.2006	FIXD


 /* If spaces in worksheet name, this undocumented range "feature" is
  * required: 
  */
proc import datafile='c:\temp\RePopulate_DATALOAD.xls' out=work.tmp 
            dbms=EXCEL2000;
  range='Advair HFA$';  /* manadatory, not sheet='Advair HFA' */
  getnames=yes;
run;
