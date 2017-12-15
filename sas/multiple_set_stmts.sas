options NOsource;
/*----------------------------------------------------------------------------
 *     Name: multiple_set_stmts.sas
 *
 *  Summary: Demo of multiple SET statements and when to use them.
 *
 *           See also merge_fast.sas
 *
 *  Created: Tue Jun 29 1999 16:08:47 (Bob Heckel)
 * Modified: Wed 31 Jul 2013 09:19:53 (Bob Heckel)
 *----------------------------------------------------------------------------
 */
options source;

data work.demo;
  infile cards missover;
  input idnum name $  qtr1-qtr4;
  cards;
1251 Rearden 10 12 14 20
161 Taggart . . 10 10
482 Galt 22 14 6 25
;
run;
title 'demo';
proc print; run;

data work.demo2;
  infile cards missover;
  input idnum othernum;
  cards;
1251 80
161 .
482 92
999 12345
;
run;
title 'demo2';
proc print; run;

options NOsource;
  /* Usually avoid using multiple SET statements in the same data step
   * because:
 
   * 1)  Observations from the end of one or more input data sets will be
   * deleted from the output data set unless all input data sets have the same
   * number of observations.
 
   * 2)  Combining several data sets into one data set with multiple SET
   * statements mimmicks a merge, but each input data step may not be in sorted
   * order and is not required to be in sorted order.
 
   * 3)  Combining several data sets into one data set with multiple SET
   * statements mimmicks a merge, but each input data step may not have matching
   * keys (even if it is in "sorted" order).
 
   * 4)  Combining several data sets through one data step and out to multiple
   * data sets runs the risk of multiplying the issues above.
 
   * 5)  From my experience, the intent that most users have in mind when using
   * multiple SET statements in the same data step is better and more
   * efficiently resolved using MERGE statements, PROC SQL. and/or other data
   * manipulation tools.
 
   * 6)  Multiple SET statements in one data step could lead to the overwriting
   * of variables with the same name, rather than appending new records
   * (or "creating" new records) as when several data sets are used in one SET
   * statement.  No warning will occur in the log if this happens.
 
   * 7)  If any of the SET statements are inside a condition, then the value of
   * the last record read will be retained for the remaining records until the
   * first time one of the input data sets encounters the end-of-data marker.
 
   * 8)  If one of the SET statements declares a data set with zero records,
   * then the resulting data set output will provide the n-1 records from the
   * iteration in which the "zero-record" data was called (it could be
   * conditional).
 
   * 9)  The SET statement wasn't designed to occur more than once in a data
   * step.  Just because it CAN be done does not mean that it SHOULD be done.
 
   * 10) Multiple SET statements in one data step are confusing, outside
   * standards, and overly challenging to support in production code.
 
   * Of course, the "IF _N_=1 THEN SET" routine is an exception that is
   * well-documented and supported by SAS, and I would exclude it from these
   * 10 points.
  */
options source;
title 'not a good idea, data is lost';
data work.foo;
  set work.demo;
  set work.demo2;
run;
proc print data=work.foo; run;

title 'single set, multiple datasets -- ok';
data work.foo2;
  set work.demo work.demo2;
run;
proc print; run;


title 'SAS idiom -- ok';
data combiner;
  put '!!!1' _all_;
  /* Start first pass to calc new variable totpay.  Keep going until end of
   * dataset. 
   */
  if _N_ = 1 then 
    do until(eof);
      put '!!!2' _all_;
      set work.demo (keep= qtr4) end=eof;
      totpay + qtr4;
    end;
  /* End first pass of ds demo. */
  /* Start second pass to calc percentage. */
  set work.demo;
  perct = qtr4 / totpay;  /* <---implied output & below this line. */
  /* End second pass of ds demo. */
run;
proc print data=_LAST_(obs=max); run;


/* Beautify. */
proc print;
  var name perct;
  sum perct;
  format perct percent7.1;
  title 'Distribution of Payroll';
run;



 /* Search a dataset for each obs of another dataset
  * http://support.sas.com/ctx/samples/index.jsp?sid=233&tab=code
  * 
  * Combining observations when there is no common variable.
  */
data cars;
  input lastname :$15. typeofcar :$15. mileage;
  datalines;
Jones Toyota 7435
Smith Toyota 13001
Jones2 Ford 3433
Smith2 Toyota 15032
Shepherd Nissan 4300
Shepherd2 Honda 5582
Williams Ford 10532
  ;
run;

data schedmaint;
  input startrange endrange typeofservice $35.;
  datalines;
3000 5000 oil change
5001 6000 overdue oil change
6001 8000 oil change and tire rotation
8001 9000 overdue oil change
9001 11000 oil change
11001 12000 overdue oil change
12001 14000 oil change and tire rotation
14001 14999 overdue oil change
15000 15999 15000 mile check
  ;
run;

/* Iterate a dataset inside a data step:
 *
 * Read the first observation from the SAS data set outside the DO loop.
 *
 * Start the DO loop reading observations from the SAS data set inside the DO 
 * loop. 
 *
 * Process the IF condition; if the IF condition is true, OUTPUT the 
 * observation and set the FOUND variable to 1.  
 *
 * Go back to the top of the DATA step and read the next observation from the
 * data set outside the DO loop and process through the DATA step again
 * until all observations from the data set outside the DO loop have been
 * read. 
 */
data combine;
  set cars;
  found=0;
  do i=1 to nobs until (found);
    set schedmaint point=i nobs=nobs;
    if startrange <= mileage <= endrange then do;
      output;
      found=1;
    end;
  end;
run;
title 'recommended service'; proc print data=_LAST_(obs=max) width=minimum; run;
