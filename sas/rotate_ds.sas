/*----------------------------------------------------------------------------
 * Program Name: rotate_ds.sas
 *
 *      Summary: Demo of rotating a dataset from "Programming SAS".
 *
 *      Created: Wed May 19 1999 14:35:50 (adapted by Bob Heckel)
 *----------------------------------------------------------------------------
 */
options linesize=80 pagesize=32767 nodate source source2 notes mprint
        symbolgen mlogic obs=max errors=5 nostimer number serror merror
        noreplace;

title; footnote;

/* Create demo used below: */
data work.donate;
  infile cards missover;
  input idnum name $  qtr1-qtr4;
  cards;
1251 Farr 10 12 14 20
161 Cox . . 10 10
482 Chin 22 14 6 25
;
run;

proc print data=work.donate; 
  title 'Before rotate';
run;

data work.rotate(drop=qtr1-qtr4);
  set work.donate(drop=idnum);
  array contrib[4] qtr1-qtr4;
  do qtr=1 to 4;
    amount = contrib[qtr];
    output;
  end;
run;

proc print data=work.rotate; 
  title 'After rotate';
run;
