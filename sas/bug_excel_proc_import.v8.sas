options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: bug_excel_proc_import.v8.sas
  *
  *  Summary: "SAS uses the first 8 rows in a column to determine the type of
  *           the variable in the SAS dataset.  And any rows with records of
  *           the opposite type will be set to missing.  So if the first 8
  *           rows are numeric but there are a few rows with character values,
  *           those rows will have missing values for the variable in the
  *           dataset." http://www.sastips.com/story.php?title=Reading-mixed-numeric%2Fcharacter-from-same-column-in-Excel-1
  *
  *           2010-06-03 if you have SAS/ACCESS installed you can bypass proc
  *           import:
  *           -apparently SAS v9.1 and Excel 2003 are ok (using LIBNAME).
  *           -apparently SAS v9.2 and Excel 2007 are ok (using LIBNAME).
  *
  *
  *           libname lx excel 'c:/temp/Zebulon_ZebAdvairGenealogy.xls' mixed=yes; 
  *           data t;
  *             set lx.'Zebulon_ZebAdvairGenealogy$'n;
  *           run;
  *
  *  Created: Wed 16 Jul 2008 13:09:12 (Bob Heckel)
  * Modified: Fri 10 Oct 2008 12:44:09 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source source2 NOcenter;

proc import datafile='Book1.xls' out=tmp dbms=EXCEL2000;
  getnames=no;  /* use F1, F2... */
  sheet="Sheet1";
run;
proc print data=_LAST_(obs=max) width=minimum; run;


 /* This is a workaround but must save xls as Excel 95 format */
proc access dbms=xls;
  create work.acc.access;
  path="Book2.xls" ;
  getnames=no;
  skiprows=0;
  mixed=yes;
  create work.inMAIN.view;
  select 1;
  list all;
run;
proc print data=_LAST_(obs=max) width=minimum; run;



endsas;
uhoh
foo
b
a
text proble
here
  123       <---numeric so missing
fu

