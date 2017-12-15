
 /* Need RLINK (OS-specific script), COMMAID (usually TCP) and REMOTE (IP
  * address or hostname) to use Connect 
  */

 /* Run via  $ sr connect.fullsample.sas (or ;z) NOT VIA sr -c ... (not ;v)! */

***filename RLINK 'K:\ORKAND\System Documentation\Programs\Signon.tcp';
filename RLINK 'c:/cygwin/home/bqh0/code/sas/Signon.mainframe.tcp';
options comamid=tcp remote=cdcjes2;
 /* These mvars resolve inside Signon.tcp */
%let userid=bqh0;
%let passwd=adaftpt8;

signon cdcjes2;
rsubmit;
  /****** run remotely *******/
  libname L 'BQH0.SASLIB' DISP=SHR;
  options nocenter;
  data tmp;
    set L.all (obs=10);
  run;
  proc print data=_LAST_(obs=max); run;
  /****** run remotely *******/
endrsubmit;
signoff cdcjes2;
