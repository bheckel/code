 /*---------------------------------------------------------------------------
  *     Name: yearcutoff_1920.sas
  *
  *  Summary: Demo of using SAS V8's default option YEARCUTOFF 1920.
  *           It's 1905 on the CDC mainframe.
  *
  *           Using default: 00...19 becomes 2000...2019
  *
  *           MS Excel uses 1930 as default yearcutoff.
  *
  *  Adapted: Thu May 30 13:03:32 2002 (Bob Heckel SUGI27 presentation Fecht)
  * Modified: Thu 08 Nov 2012 10:24:58 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options linesize=92 pagesize=32767 nodate source source2 notes mprint
        symbolgen mlogic obs=max errors=5 nostimer number serror merror
        noreplace datastmtchk=allkeywords nocenter;

 /* Verify (in Log) it's 1920 */
proc options option=YEARCUTOFF; run;

 /* E.g. 1920 yearcutoff forces '20 to mean 1920, '03' to mean 2003. */
data work.yearcutoff;
  yc=getoption('yearcutoff');
  do the_year = 0 to 101;
    the_imputed_date = mdy(1, 1, the_year);
    output;
  end;
run;

proc print obs='Observation Sequence Number';
  format the_year Z2.  the_imputed_date yymmddP10.;
run;



 /* Interesting error, the too short informat reads "19" which becomes 2019 */
data t;
  input d MMDDYY8.;
  cards;
12/08/1925
  ;
run;
proc print data=_LAST_(obs=max) width=minimum; format d DATE9.; run;
 /*
Obs        d

 1     08DEC2019
  */

