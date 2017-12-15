options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: eval.sas
  *
  *  Summary: Embedded macro call in a string.
  *
  *           %let d=%eval(10+20);        Correct usage 
  *           %let d=%eval(10.0+20.0);    Incorrect usage, use %sysevalf()
  *
  *  Created: Tue 14 Dec 2004 15:15:11 (Bob Heckel)
  * Modified: Thu 03 Sep 2009 12:10:23 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source NOcenter;

%let YEAR=2004;

%let YEAR=%eval(&YEAR+1);

LIBNAME REGI1 "c:/Temp/&YEAR";
LIBNAME REGI0 "c:/Temp/%eval(&YEAR-1)";

%put _all_;
