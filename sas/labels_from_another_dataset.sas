/* From SAS Samples sas.com 2007-02-09 */

/* Example 1: Use the values from one data set to create labels for another */
/*            data set                                                      */

/* Create sample data sets.  The values from WORK.ONE will be used as  */
/* variable labels for WORK.TWO.                                       */


data one;
  infile datalines dsd;
  input var1 :$11. var2 :$11. var3 :$11.;
  datalines;
Label One,Label Two,Label Three
  ;
run;
proc print data=_LAST_(obs=max); run;

data two;
  input var1 :$11. var2 :$11. var3 :$11.;
  datalines;
a b c
d e f
  ;
run;
proc print data=_LAST_(obs=max); run;


/* Create a macro to generate labels from values in the first data set and apply */
/* the new labels to variables in the second data set.                           */
%macro labels(dsn1,dsn2);
  /* Open dataset whose values in the first observation will become new labels */
  %let dsid=%sysfunc(open(&dsn1));

  /* CNT will contain the number of variables in &dsn1 */
  %let cnt=%sysfunc(attrn(&dsid,nvars));

  %do i = 1 %to &cnt;
    /* Create a different macro variable for each variable name in &dsn1 */
    %let x&i=%sysfunc(varname(&dsid,&i));
  %end;

  /* Create macro variables for each value in the first observation in &dsn1 */
  data _null_;
    set &dsn1;
    if _n_ = 1 then do;
      %do j = 1 %to &cnt;
	/* Note: If you are in SAS 9 or above, you can use CALL SYMPUTX to
	 * remove leading and trailing blanks.
	 * */
        call symput('var'||trim(left(&j)),&&x&j);
      %end;
    end;
  run;

  /* Use the macro variables to generate a LABEL statement in PROC DATASETS. */
  proc datasets library=work nolist;
    modify &dsn2;
    label
      %do i = 1 %to &cnt;
         &&x&i=&&var&i
      %end;
     ;
  quit;
%mend labels;


/* Call the macro LABELS with two data sets.  The first parameter specifies
 * the data set whose values will become the new labels.  The second parameter
 * specifies the data set that will receive the new labels.  
 */
%labels(one,two)

/* Check the results. */
proc print data=two label; run;



/* Example 2: Reading a flat file whose first record is meant to be variable */
/*            names but are invalid SAS variable names.  Create labels from  */
/*            the first record instead.                                      */

/* Create sample test file to be read. */
data _null_;
  file "c:\temp\sample1727.txt";

  put "2005,2006,2007,Total Revenue";
  put "1,2,3,25000";
  put "4,5,6,50000";
run;

/* Read only the first record from SAMPLE1727.TXT using OBS=1 on the INFILE
 * statement. 
 */
data one_2;
  infile "c:\temp\sample1727.txt" dsd obs=1;
  input var1 :$4. var2 :$4. var3 :$4. var4 :$13.;
run;

/* Read the rest of the flat file to create a second data set of data values
 * only using FIRSTOBS=2 on the INFILE statement.
 */
data two_2;
  infile "c:\temp\sample1727.txt" dsd firstobs=2;
  input var1 var2 var3 var4;
run;

/* Pass these two data sets as the parameters to the macro LABELS illustrated
 * in Example 1. 
 */
%labels(one_2,two_2)

proc print data=two_2 label;
run;
