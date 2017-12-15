options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: concatenate.sas
  *
  *  Summary: Concatenating datasets and variables.  
  *           To concat strings use || or !! (mainframe)
  *
  *  Created: Thu 19 Jun 2003 12:10:01 (Bob Heckel)
  * Modified: Fri 11 Jun 2010 13:42:54 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source;

data work.tmp1;
  input fname $1-10  lname $15-25  @30 numb 3.;
  datalines;
mario         lemieux        679
ron           francis        123
  ;
run;
proc print; run;


data work.tmp2;
  input fname $1-10  lname $15-25  @30 numb 3.;
  datalines;
larry         wall           345
richard       dawkins        345
richard       feynman        678
  ;
run;
proc print; run;


 /* Caution: for common variables, SAS uses the descriptor info from the first
  * ds if they are not the same for both ds.  Use proc append BASE=ds to
  * control which ds is used.
  */
data work.concat;
  set work.tmp1 work.tmp2;
run;
proc print; run;


data concat (keep= combined);
  set tmp2;
  combined = fname || lname || numb;
run;
proc print data=_LAST_; run;



data _null_;
  length cat1-cat4 $15;

  One = ' ABC ';
  Two = 'XY Z';

  one_two = ':' || One || Two || ':';
  trim = ':' || trimn(One) || Two || ':';  /* trailing blanks removed */
  strip = ':' || strip(One) || strip(Two) || ':';  /* leading and trailing blanks removed */

  /*
    CAT:   concatenates character strings without removing leading or trailing blanks
    CATS:  concatenates character strings and removes leading and trailing blanks
    CATT:  concatenates characters strings and removes trailing blanks
    CATX:  concatenates character strings, removes leading and trailing blanks, and inserts separators
   */
  cat1 = cat(':',One,Two,':');
  cat2 = cats(':',One,Two,':');
  cat3 = catt(':',One,Two,':');
  cat4 = catx(',',One,Two);

  put one_two= / trim= / strip= / (cat1-cat4)(= /);
run; 



 /* Demonstrates the difference in how missing values are handled */
data test;
  x1='4';
  x2=' ';
  x3='2';
  oldx=trim(left(x1))||','||trim(left(x2))||','||trim(left(x3));
  newx=catx(',', of x1-x3);
  put oldx= / newx=;
run;
