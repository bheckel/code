
%let sysparm=c:\cygwin\home\bheckel\tmp\17Jun09_1245252516;
%let DLIPATH=&SYSPARM\;
libname myscl ".";

/***proc display c=myscl.catalog.ADO.scl; run;***/
proc display c=myscl.catalog.B21.scl; run;
