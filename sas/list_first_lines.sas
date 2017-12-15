options nosource;
 /*---------------------------------------------------------------------
  *     Name: list_first_lines.sas
  *
  *  Summary: View a few lines of an input file.  Also a good demo of
  *           using SAS Connect remote work library.
  *
  *  Created: Thu 05 Jun 2003 08:37:01 (Bob Heckel)
  *---------------------------------------------------------------------
  */
options source;

%include "&HOME/code/sas/connect_setup.sas";
signon cdcjes2;


 /******************On the mainframe********************/
rsubmit;

%sysrput rwork=%sysfunc(pathname(work));

%global FN;
***%let FN=BF19.NJX0301.MORMER;
%let FN=BF19.CAX0301.NATMER;
 /* TODO pass line length in macrovar */

filename IN "&FN" WAIT=3;

data tmpds;                                                                    
  infile IN OBS=5;
  input @1 tmp $char786.;
run;

endrsubmit;



 /*********************On the PC***********************/
 /* Use the remote work libray locally. */
libname RWORK "&rwork." server=cdcjes2;

 /* TODO how to exceed lrecl 256 on Windows? */
filename OUT 'junk.dat' LRECL=786;
data _NULL_;
  set RWORK.tmpds;
  file junk;
  put tmp;
run;

signoff cdcjes2;
