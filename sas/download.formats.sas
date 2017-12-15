options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: download.formats.sas
  *
  *  Summary: Transport a format catalog from one platform to another.
  *
  *           Run via PC SAS.
  *
  *  Created: Wed 16 Feb 2005 10:06:15 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source NOcenter;

libname WIN 'c:/cygwin/home/bqh0/tmp/testing/suns';

%include "&HOME/code/sas/connect_setup.sas";
signon cdcjes2;
rsubmit;

  ***libname MVS 'BQH0.FMTS.SASLIB' DISP=SHR WAIT=10;
  libname MVS 'DWJ2.NAT2003.FMTLIB' DISP=SHR WAIT=10;
  proc download incat=MVS.formats outcat=WIN.formats ;
    ***select name1 name2 name2.format name3 name4.format /et=formatc ;
  run;

endrsubmit;
signoff cdcjes2;

 /* now run formatprint.sas to make sure it worked */
