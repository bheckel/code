 /*---------------------------------------------------------------------------
  *     Name: run_external_pgm.sas
  *
  *  Summary: Demo of running an external program via SAS (flexcode).
  *
  *  Adapted: Tue May 14 17:38:57 2002 (Bob Heckel -- Professional SAS
  *                                     Programming Secrets - Rick Aster)
  *---------------------------------------------------------------------------
  */
options linesize=72 pagesize=32767 nodate source source2 notes mprint
        symbolgen mlogic obs=max errors=5 nostimer number serror merror
        noreplace datastmtchk=allkeywords;

title; footnote;

data _NULL_;
  file 'junk.bat';
  TODAY = today();
  put 'echo today is ' TODAY YYMMDDN8. /
      'pause';
run;

x 'junk.bat';


/* TODO */
/***
data _NULL_;
  TODAY = today();
  file 'junk.pl';
  put 'print today is ' TODAY YYMMDDN8.;
run;

x 'c:\cygwin\bin\perl junk.pl';
***/
