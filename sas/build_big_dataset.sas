options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: build_big_dataset.sas
  *
  *  Summary: Create a very large dummy dataset.
  *
  *  Created: Fri 11 Sep 2009 10:10:33 (Bob Heckel)
  * Modified: Wed 17 Aug 2016 13:52:49 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source NOcenter;

options NOmlogic NOmprint NOsgen;
%let REPS=3;

%macro m;
  %global DS;
  %do i=1 %to &REPS;
    %let DS=&DS SASHELP.shoes;
  %end;
%mend;
%m

data big;
  set &DS;
run;


 /* Better */
data _null_;
  call symput('SINGLEMVAR', repeat('SASHELP.shoes ', &REPS));
run;

data stacked;
  /* Avoid "wallpaper code" */
/***  set SASHELP.shoes SASHELP.shoes SASHELP.shoes SASHELP.shoes SASHELP.shoes SASHELP.shoes ... ;***/
  set &SINGLEMVAR;
run;
proc print data=_LAST_(obs=5) width=minimum; run;


 /* Best */
 /*                                                     100%                 */
proc surveyselect data=SASHELP.shoes out=stacked2 samprate=1 reps=&REPS; run;
proc print data=_LAST_(obs=5) width=minimum; run;
