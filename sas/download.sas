options source mlogic mprint sgen;

 /* Download a dataset.  The dataset is automatically converted to be used on
  * the local platform.  See download.formats.sas if need to download a format
  * catalog.
  *
  * Use CONNECTSTATUS=no if on a non-PC or non-X box.
  */

 /* !!!!!!!!!!! Use ;z to run !!!!!!!!!!! */
 /* !!!!!!!!!!! Use ;z to run !!!!!!!!!!! */
 /* !!!!!!!!!!! Use ;z to run !!!!!!!!!!! */

 /*---------------Put Here---------------------*/
 /* This is recognized on the mainframe-run portion of code (somehow) */
libname LOCAL 'c:/cygwin/home/bqh0/tmp/testing';
***libname LOCAL 'c:/cygwin/home/bqh0/tmp/testing/suns/1999';
***libname LOCAL 'c:/cygwin/home/bqh0/tmp/testing/';
***libname LOCAL 'i:/cabinets/tsb/excel';
 /*---------------Put Here---------------------*/


%include 'c:/cygwin/home/bqh0/code/sas/connect_setup.sas';
signon cdcjes2;
rsubmit;

   /*-------------From There----------------------*/
   /* code goes here to be executed on the mf */
  ***libname REMOTE 'BQH0.SASLIB' DISP=SHR;
  ***libname REMOTE 'DWJ2.USTOT.SASLIB' DISP=SHR;
  ***libname REMOTE '/u/dwj2/register/NAT/2003/';
  ***libname REMOTE '/u/dwj2/mvds/NAT/2004/';
  ***libname REMOTE 'DWJ2.NAT1999.MVDS.LIBRARY.NEW' DISP=SHR WAIT=10;

  proc download data=SASHELP.shoes out=LOCAL.shoes;
  ***proc download data=REMOTE.UST2003OLDNAT out=LOCAL.UST2003OLDNAT status=no;
  ***proc download data=REMOTE.register out=LOCAL.register;
  ***proc download data=REMOTE.gaold out=LOCAL.gaold;
  run;
   /*-------------From There----------------------*/

endrsubmit;
signoff cdcjes2;

 /* !!!!!!!!!!! Use ;z to run !!!!!!!!!!! */
 /* !!!!!!!!!!! Use ;z to run !!!!!!!!!!! */
 /* !!!!!!!!!!! Use ;z to run !!!!!!!!!!! */
