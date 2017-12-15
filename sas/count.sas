options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: count.sas
  *
  *  Summary: Count all obs.
  *
  *            ___CHECK TOTAL MVDS COUNT___
  *
  *  Created: Tue 07 Jun 2005 14:44:22 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source NOcenter NOreplace;

libname L '/u/dwj2/mvds/NAT/2003'; 

data _null_;
  file PRINT;
  numobs=attrn(open('L.NYOLD'), 'nobs');
  put numobs COMMA8.;
run;
