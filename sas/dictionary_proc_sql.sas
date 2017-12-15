options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: dictionary_proc_sql.sas
  *
  *  Summary: Programatically access a library or dataset's metadata.
  *
  *           DICTIONARY is a built-in libref
  *
  *           file:///C:/Bookshelf_SAS/proc/zsqldict.htm
  *
  *  Created: Tue 17 Aug 2004 12:34:11 (Bob Heckel)
  * Modified: Fri 23 Jan 2015 12:58:14 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source NOcenter mlogic mprint sgen ls=180 NOlabel;

 /* Prints to Log the CREATE TABLE statements SAS used to build table */
proc sql;
  /* Meta dictionary */
  describe table dictionary.dictionaries;
   ***describe table dictionary.catalogs;
   ***describe table dictionary.columns;
   ***describe table dictionary.extfiles;
   ***describe table dictionary.indexes;
   ***describe table dictionary.macros;
   ***describe table dictionary.members;
   ***describe table dictionary.options;
   ***describe table dictionary.tables;
   ***describe table dictionary.titles;
   ***describe table dictionary.views;
quit;


data work.t;
  input @30 numb 3.  fname $1-10  lname $15-25;
  datalines;
mario         lemieux        123
jerry         garcia         123
richard       feynman        678
  ;
run;

proc sql;
  select *
/***  from dictionary.catalogs***/
  from dictionary.columns
/***  from dictionary.extfiles***/
/***  from dictionary.indexes***/
/***  from dictionary.macros***/
/***  from dictionary.members***/
/***  from dictionary.options***/
/***  from dictionary.tables***/
/***  from dictionary.titles***/
/***  from dictionary.views***/
  where libname eq 'WORK'
  ;
quit;

 /* Compare: */
proc contents data=WORK._ALL_; run;



endsas;
libname MVDS1 'DWJ2.MED2003.MVDS.LIBRARY.NEW' DISP=SHR;
libname MVDS2 'DWJ2.MED2004.MVDS.LIBRARY.NEW' DISP=SHR;
proc sql NOPRINT;
  select memname into :DSETS separated by ' '
  from dictionary.members
  /* Case sensitive! */
  where libname like 'MVDS%' and memname like '%NEW'
  ;
quit;

%put !!! &DSETS;



title 'label of var "fname"';
proc sql;
  select label from dictionary.columns
  where libname eq 'WORK' and name eq 'fname'
  ;
quit;

title 'count of records in ds "sample"';
proc sql;
  select nvar from dictionary.tables
  where libname eq 'WORK' and memname eq 'SAMPLE'  /* uppercase! */
  ;
quit;

proc sql NOPRINT;
  select nvar INTO :NVAR from dictionary.tables
  where libname eq 'WORK' and memname eq 'SAMPLE'  /* uppercase! */
  ;
quit;
%put !!!&NVAR;

title 'creating a view';
proc sql NOPRINT;
  create view vcolumn as
  select * from DICTIONARY.COLUMNS
  where libname='WORK' and memname='SAMPLE';
quit;
proc print data=vcolumn(obs=max); run;



data tmp; 
  set SASHELP.vsview;
  where libname eq 'SASHELP' and substr(memname, 1, 1) eq 'V';
run;
proc print data=_LAST_; run;

 /* compare */

 /* TODO how to get the var names and not labels on SQL prints?  Using this
  * hack to get around it for now
  * edit 23-Jan-15: use:  options NOlabel;
  */
proc sql NOPRINT;
  create table tmp2 as
  select * 
  from dictionary.views
  where memname like 'V%'
  ;
quit;
proc print data=_LAST_; run;
