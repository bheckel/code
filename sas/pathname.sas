options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: pathname.sas
  *
  *  Summary: Determine physical path of a libname library.
  *
  *  Created: Thu 11 Sep 2003 15:24:42 (Bob Heckel)
  * Modified: Mon 22 Sep 2008 12:19:32 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source;

libname BOBH 'c:/temp';

data _null_;
  length fname $5000;
  
  workdir=pathname('WORK');
  put workdir=;

  mypath=pathname('BOBH');
  put mypath=;

  fname=pathname('SASHELP');
  put fname=;
run;

%put %sysfunc(pathname(SASAUTOS));
