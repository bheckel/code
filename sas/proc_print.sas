options nosource;
 /*---------------------------------------------------------------------
  *     Name: proc_print.sas
  *
  *  Summary: Demo of using proc print to query a dataset.
  *           Use proc report for more horsepower.
  *
  *           CANNOT FORMAT ON THE VAR STATEMENT!
  *
  *           Bug in v8 if use ls=max may not have enough memory, 
  *           use ls=256 or less to get around it.
  *           Or better: 
  *           data _null_; set _LAST_; file LOG; put (_ALL_)(=); put; run;
  *
  *           See var_wildcard.sas to print only a pattern of vars.
  *            
  *           See printall_dataset.sas if you don't know the ds name.
  *
  *  Adapted: Mon 28 Oct 2002 12:32:55 (Bob Heckel -- Rick Aster SAS
  *                                     Programming Shortcuts p. 270)
  * Modified: Fri 01 Feb 2008 15:44:08 (Bob Heckel)
  *---------------------------------------------------------------------
  */
options source nodate byline pagesize=40 ls=80 number pageno=66;

 /* Avoid really long vars from causing wrapping: */
proc print data=_LAST_ width=MINIMUM; 
  /* length statement doesn't work here */
  var specname varname colname elemstrval;
  where samp_id=244243;
run;



data work.sample;
  input fname $1-10  lname $15-25  @30 numb 3.;
  label fname='First*Name';
  datalines;
mario         lemieux        123.4
ron           francis        123
jerry         garcia         123
berry         garcia         123
larry         wall           345
  ;
run;
proc print data=_LAST_(obs=max); run;


title 'ID and VAR for same variable prints the variable twice';
proc print data=work.sample;  /* NOOBS is implied by the ID statement */
  /* ID replaces the Obs column (it's most useful when the number of
   * variables is high and the output results wrap):
   */
  id lname;
  var numb lname fname;
run;


title 'Temporarily adjust output format.  Limit observations to a subset of 4';
 /*        Mandatory if using (obs= )  */
 /*        ________________            */
proc print data=work.sample (obs= 4);
  format numb DATE8.;
  var numb lname;
run;


title 'One approach if you enjoy using parentheses:';
 /* Must use data= (will not default)! */
proc print data=_LAST_(obs=max where=(numb=123 and lname='garcia'));
run;


title 'Better:';
proc print;
  where numb=123 and lname='garcia';
run;


title 'Worse:';
data work.query;
  set work.sample;
  /* Subsetting IF */
  if numb=123 and lname='garcia';
run;
proc print; run;


title 'Worse still:';
data work.query;
  set work.sample;
  /* Note the OR instead of AND here. */
  if numb ^= 123 or lname NE 'garcia' then delete;
run;
 /* SAS' hack required for proc print to use label information. */
proc print LABEL split='*'; run;


title 'Compare with SQL:';
proc sql NUMBER;
  select * from _LAST_
  where numb = 123 and lname = 'garcia';
quit;


title 'Spreadsheet-like:';
 /* Suppress observation numbers. */
 /*                         _____ */
proc print HEADING=VERTICAL NOOBS;
  where numb=123 and lname='garcia';
run;


title 'Group by:';
proc sort data=work.sample;
  by numb;
run;
proc print data=work.sample;
  by numb; 
run;


title 'Using labels (want blank first name label) and underlining:';
proc print LABEL split='*' NOOBS N;
  /*               underline hack    */
  label numb = 'The*Number*======'
        lname = 'The*Last*Name'
        fname = '00'x;
        ;
run;

title "Using subtotals (proc print's SUMBY statement, no totals calc):";
proc print;
  by numb;
  sumby numb;
run;

proc sort data=work.sample;
  by lname;
run;
title "Using subtotals (proc print's SUM statement, with totals calc):";
proc print;
  by lname;
  /* proc print version of sum statement. */
  sum numb;
run;

title 'Using subtotals with ID (cleaner-no lname=foo dividers, nor obs numbers):';
proc print DOUBLE;
  sum numb;
  by lname;
  id lname;
run;


title 'Rounded to 2 decimal points without using formats using ROUND keyword';
data tmp;
  input floatingpt;
  cards;
1.23456
7.89012
  ;
run;
proc print ROUND; run;


 /* Mandatory. */
proc sort data=sample;
  by lname;
run;
title "Using proc print's PAGEBY statement (must have a BY statement)";
proc print data=sample;
  by lname;
  pageby lname;
run;


title 'Colon wildcard - print only vars starting with the letter "l"';
proc print data=_LAST_(obs=max); 
  var l:;
run;



ods excel file="/Drugs/RFD/2017/02/AN-6617/Reports/AN-6617.xlsx";
  ods excel options(sheet_name="6 mo lookback");
  proc print data=output2  NOobs; sum count; run;
  ods excel options(sheet_name="12 mo lookback");
  proc print data=output3  NOobs; sum count; run;
ods excel close;
