
 /* This file will be injected into code like so:
  *
  *   %include 'c:/cygwin/home/bqh0/code/sas/connect_setup.sas';
  *   signon sunstat;
  *   rsubmit;
  *     ...SAS code to run on MF...
  *   endrsubmit;
  *   signoff sunstat;
  *   
  */
%let sunstat=158.111.202.54;
%let localhome=%sysget(HOME);
 /* Initiate conversation.  Unix version: */
%let signon="&localhome/code/sas/Signon.unix.tcp";
 /* Run the Connect script file. */
filename RLINK &signon;
options comamid=TCP remote=sunstat;
