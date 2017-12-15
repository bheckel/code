options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: informat.sas
  *
  *  Summary: Demo of the informat statement, a way of reading nonstandard
  *           data (e.g. numbers containing commas, dollar signs, dates in
  *           non-SAS standard date format).
  *
  *  Created: Thu 15 May 2003 09:19:55 (Bob Heckel)
  * Modified: Thu 10 Oct 2013 08:24:54 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source;

data tmp;
  /* Note - '5' doesn't count the dash! */
  input adate :MONYY5.  anum;
  datalines;
jan--60 129.9
jul-90 130.4
sep-90 132.7
jul-91 136.2
  ;
run;
proc print data=_LAST_(obs=max) width=minimum; 
  format adate DATE9.;
  var adate anum;
run;



endsas;
 /* Example 1 */

data tmp;
  informat adate MONYY7.;
  input adate anum;
  datalines;
jun1960 129.9
jul1990 130.4
sep1990 132.7
jul1991 136.2
  ;
run;
title 'informat MONYY7. but no format';
proc print data=tmp; run;
proc contents data=tmp; run;

data tmp;
  input adate :MONYY7.  anum;
  datalines;
jun1960 129.9
jul1990 130.4
sep1990 132.7
jul1991 136.2
  ;
run;
title 'compare';
proc print data=tmp; run;
proc contents data=tmp; run;

title 'temporary YYMMDD8. format applied';
proc print data=tmp; 
  format adate YYMMDD8.;
  var adate;
run;


 /* Example 2 */

data tmp2;
  /* Raw data (non-standard to SAS) */
  informat adate MONYY7.;
  /* How you want to see it later */
  format adate MONYY5.;
  input adate anum;
  datalines;
jun1990 129.9
jul1990 130.4
sep1990 132.7
jul1991 136.2
  ;
run;

 /* Almost the same but informat doesn't get stored, right?? */
data tmp2;
  format adate MONYY5.;
  input adate MONYY7.  anum;
  datalines;
jun1990 129.9
jul1990 130.4
sep1990 132.7
jul1991 136.2
  ;
run;
title 'informat MONYY7. permanent format MONYY5.';
proc print data=tmp2; run;
proc contents data=tmp2; run;
