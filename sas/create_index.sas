options nosource;
 /*---------------------------------------------------------------------------
  *     Name: create_index.sas
  *
  *  Summary: Demo of creating an index to speed up searching and sorting.
  *           An index allows you to locate an observation by value instead of
  *           going obs by obs until SAS finds your target.
  *
  *           A general rule of thumb is to use an index only if 15% or fewer
  *           observations are accessed (and don't index if the "Number of
  *           Data Set Pages" is < 3) or if the index can be reused.
  *
  *  Adapted: Tue 29 Oct 2002 14:24:05 (Bob Heckel -- Rick Aster SAS
  *                                     Programming Shortcuts p. 49)
  * Modified: Tue 15 Dec 2015 13:56:36 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source replace;

proc sql;
   create index places on sql.newcountries(name, continent);
quit;



***libname BOBH 'c:\Temp';
***libname BOBH v8 'c:\Temp';
 /* Use SAS engine version 6  for demo. */
/***libname BOBH v609 'c:\Temp';***/

 /* The proc datasets method: */
data work.sample;
  input fname $1-10  lname $15-25  @30 numb 3.;
  datalines;
mario         lemieux        123
ron           francis        123
jerry         garcia         123
larry         wall           345
richard       dawkins        345
richard       dawkins        345
richard       feynman        678
  ;
run;

proc datasets library=work NOLIST;
  modify sample;
  /* Simple index, keyname is automatically the varname */
  ***index create lname;
  /* Composite index */
  index create keyname=(lname fname);
run;


 /* The INDEX= dataset method (simple index): */
 /* Double parens are mandatory */
data work.sample2 (index=(numb));
  input fname $1-10  lname $15-25  @30 numb 3.;
  datalines;
mario         lemieux        123
ron           francis        123
jerry         garcia         123
larry         wall           345
richard       dawkins        345
richard       dawkins        345
richard       feynman        678
  ;
run;


 /* The proc sql method (simple index): */
data work.sample3;
  input fname $1-10  lname $15-25  @30 numb 3.;
  datalines;
mario         lemieux        123
ron           francis        123
jerry         garcia         123
larry         wall           345
richard       dawkins        345
richard       dawkins        345
richard       feynman        678
  ;
run;


proc sql;
  create index fname on work.sample3 (fname);
quit;

proc contents data=work._ALL_; run;
