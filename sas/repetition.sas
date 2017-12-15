options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: repetition.sas
  *
  *  Summary: Generate a repeating character string based on 
  *           a certain number of repetitions.
  *
  *  Created: Tue 01 Jul 2003 10:14:29 (Bob Heckel)
  * Modified: Fri 09 May 2008 15:33:14 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source;

/*** %let S=0; ***/
%let S=b;
%let REPS=3;

data _NULL_;
  length s $&REPS;
  do i=1 to &REPS;
    s="&S"||s;
  end;
  put s=;
run;


data _null_;
  call symput('SINGLEMVAR', repeat('SASHELP.shoes ', &REPS));
run;

data stacked;
  /* Avoid "wallpaper code" */
/***  set SASHELP.shoes SASHELP.shoes SASHELP.shoes SASHELP.shoes SASHELP.shoes SASHELP.shoes ... ;***/
  set &SINGLEMVAR;
run;
proc print data=_LAST_(obs=5) width=minimum; run;

 /* Better? */
 /*                                                     100%                 */
proc surveyselect data=SASHELP.shoes out=stacked2 samprate=1 reps=&REPS; run;
proc print data=_LAST_(obs=5) width=minimum; run;

%put _all_;
