 /*----------------------------------------------------------------------------
  *   Program Name: duplicates_rpt.sas
  *
  *        Summary: List obs with duplicate keys and then count the dups.
  *                 Checks ds that should only hold unique values.
  *
  *         Inputs: dsname    dataset of interest.
  *                 byvars    one or more variables that compose the key.
  *                 out=      output ds containing dups.
  *                 opts=     whether or not to print to Output Window.
  *
  *          Usage: 
  *            %DuplicatesReport(WORK.myds, job_id, out=WORK.myoutds, PRINT);
  *
  *
  *          May be easier to use proc sql's count(), see dup_count.sql.sas
  *
  *      Generated: 6/27/91 (R. DeVenezia)
  * Modified: Thu 19 Jan 2006 15:27:21 (Bob Heckel)
  *----------------------------------------------------------------------------
  */

%macro DuplicatesReport(dsname, byvars, out=, opts=);
  %if (&out ne) %then %let dupls = &out;
  %let dsname = %upcase(&dsname);
  %let byvars = %upcase(&byvars);
  /* Scan the byvars for the last by variable. */
  %let prevby = %str();
  %let currby = %scan(&byvars, 1);
  %let i = 1;
  %do %while(&currby ne %str());
    %let i = %eval(&i + 1);
    %let prevby = &currby;
    %let currby = %scan(&byvars, &i);
  %end;
  %let lastby = &prevby;

  /* Sort the key values in their own ds. */
  proc sort data=&dsname(keep=&byvars) out=work.byset;
    by &byvars;
  run;

  /* Determine duplicate key values and their counts. */
  data &dupls;
    set work.byset;
    by &byvars;
    /* Initialize duplication count. */
    if first.&lastby then
      duplcnt = 0;
      duplcnt + 1;
    /* At last duplication (i.e. > 1 count), save obs. */
    if last.&lastby and not first.&lastby then output; 
  run;

  %if(%index(%upcase(&opts), NOPRINT) eq 0) %then %do;
    /* Report duplication findings. */
    title1 "Dups in &dsname keyed by Variable(s) &byvars";
    proc print; run;

  %end;
%mend DuplicatesReport;
libname j 'c:/cygwin/home/bheckel/tmp/';
%DuplicatesReport(j.lelimsgist_indres01a, samp_id, out=work.tmp print);

endsas;
/* Sample call: */
/***%DuplicatesReport(work.testing, 
              namea nameb, 
              out=work.tested, 
              opts=PRINT);
***/


/* Test data: */
options linesize=80 pagesize=32767 nodate source source2 notes mprint
            symbolgen mlogic obs=max errors=3 nostimer number;

title; footnote;

data work.testing;
  input namea $  nameb $  var1-var3;
  cards;
one aaa 3 6 9
two bbb 10 12 14
three ccc 15 17 19
three ccc 15 17 19
three xcc 15 17 19
four ddd 21 24 28
five ddd 32 33 34
five ddd 32 33 34
;
run;
