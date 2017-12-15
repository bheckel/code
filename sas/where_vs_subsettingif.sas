options nosource;
 /*---------------------------------------------------------------------------
  *     Name: where_vs_subsettingif.sas
  *
  *  Summary: Subsetting IFs can appear only in DATA steps, WHERE
  *           statements can appear in DATA or PROC steps.
  *
  *           Subsetting IF:
  *           if x >=0;  
  *           same as  if x < 0 then delete;  
  *           same as  if not (x < 0);
  *
  *           Think of the preprocessor to determine whether WHERE will work.
  *           So it won't work for INPUT or assignment statements.
  *
  *           Also won't work if the variable of interest isn't in all
  *           datasets.
  *
  *  Adapted: Thu 11 Apr 2002 14:41:23 (Bob Heckel--Little SAS Book)
  * Modified: Sun 01 Jun 2003 09:54:38 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source fullstimer;


data work.sample;
  input fname $ 1-10  lname $ 15-25  @30 numb 3.;
  datalines;
jerry         garcia         123
berri         garcia         123
zerri         Garcia         123
larry         wallcia        345
richard       dawkins        345
richard       feynman        678
  ;
run;


data work.tmp;
  set work.sample;
  if lname eq 'garcia';
run;
proc print; run;


data work.tmp;
  set work.sample;
  /* Same */
  ***where lname eq 'garcia';
  /* Same but parenthesis give more flexible SQL-like pattern matching */
  ***where (lname like 'gar%');
  ***where (lname contains 'gar');
  ***where (lname ? 'gar');
  where lname ? 'gar';
run;
proc print; run;


 /* Same as previous block but using the WHERE= dataset option. */
data work.tmp (where= (lname eq 'garcia'));
  set work.tmp;
run CANCEL;
proc print; run CANCEL;
data work.tmp;
  set work.tmp (where= (lname eq 'garcia'));
run;
proc print; run;
