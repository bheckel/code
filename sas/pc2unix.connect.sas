options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: pc2unix.connect.sas
  *
  *  Summary: Connect from PC to Unix.
  *
  *  Created: Tue 23 Mar 2004 16:21:27 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source;

%let REMOTEBOX=158.111.202.124;
options comamid=tcp remote=REMOTEBOX;
filename rlink 'Signon.unix.tcp';

signon REMOTEBOX;
rsubmit;
  data _null_;
    put "!!!operating system is &SYSSCP (&SYSSCPL)";
  run;
endrsubmit;
