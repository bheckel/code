options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: best.sas
  *
  *  Summary: Demo of using SAS' default NUMERIC format, BEST.  Use it if
  *           you're not sure how many decimals you'll have.
  *
  *  Created: Tue 10 Jun 2003 09:25:00 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source;

data _NULL_;
  s=1234567;
  put @1 s BEST12.;
  put @1 s BEST8.;
  put @1 s BEST6.;
  put @1 s BEST3.;
  put @1 s BEST2.;
run;
