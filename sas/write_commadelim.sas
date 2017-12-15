 /* See quote_and_commaseparate.sas */

/*******************************************************************\           
| Copyright (C) 1999 by SAS Institute Inc., Cary, NC, USA.          |           
|                                                                   |           
| SAS (R) is a registered trademark of SAS Institute Inc.           |           
|                                                                   |           
| SAS Institute does not assume responsibility for the accuracy of  |           
| any material presented in this file.                              |           
\*******************************************************************/
/*  Writing a Comma Delimited File With PUT Statements  */

/* Adapted: Tue Jan 14 15:23:45 2003 (Bob Heckel) */

/* Probably easier to just use DELIMITER=',' on a FILE statement. */

data work.one;
  input w x y z;
  cards;
1 2 3 4
3 4 5 6
6 6667 77 7777
  ;
run;

data _NULL_;
  set work.one;
  /* Print to LOG (normally we'd print to a file). */
  file PRINT NOTITLES;
  /* The '--' between in x--z means to take all variables in the PDV starting
   * at x and ending at z and write them.  This completely depends on the
   * order that they show up in the PDV.  This can be determined by using PROC
   * CONTENTS.  Also, I found that I had to have the first variable listed
   * outside of the () to keep SAS from putting a leading ',' .  You can see
   * how this method requires a fair amount of prior knowledge about your
   * dataset, but it does reduce some of the tedium. 
   */
  ***put @1 w +(-1)','  x +(-1)','  y +(-1)','  z;
  put @1 w (x--z) (+(-1) ',');
run;



 /* Write comma delimited.  Also good demo of the file statement. */
data work.goodrestaurants;
  set work.restaurants;
  /* Write (or overwrite) to junk.dat in PWD. */
  file junk dlm=',';
  if name ne "Arbys" then
    put name addr phone web city zip;
run;
