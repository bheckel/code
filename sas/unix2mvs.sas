options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: unix2mvs.sas
  *
  *  Summary: Connect from Unix to mainframe.
  *
  *  Created: Thu 17 Mar 2005 13:34:54 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source;

%let REMOTEBOX=158.111.2.21;
options comamid=tcp remote=REMOTEBOX;
 /* Assumes we've hardcoded the userid and passwd mvars */
filename rlink 'Signon.tcp';

signon REMOTEBOX;
rsubmit;
  data _null_;
    put "!!!operating system is &SYSSCP (&SYSSCPL)";
  run;
endrsubmit;
