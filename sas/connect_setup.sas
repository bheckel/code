 /* This file will be injected into code like so:
  *
  *   %include 'c:/cygwin/home/bqh0/code/sas/connect_setup.sas';
  *   signon cdcjes2;
  *   rsubmit;
  *    ...SAS code to run on MF...
  *   endrsubmit;
  *   signoff cdcjes2;
  *   
  */
%let cdcjes2=158.111.2.21;
%let localhome=%sysget(HOME);
 /* Initiate conversation.  Mainframe version: */
%let signon="&localhome/code/sas/Signon.mainframe.tcp";
 /* Run the Connect script file. */
filename RLINK &signon;
options comamid=TCP remote=cdcjes2;

 /* For Signon.tcp: */
%let userid=%sysget(USERNAME);
%let passwd=ntbwasss;
***%let userid=bhb6;
***%let passwd=sunshine;
