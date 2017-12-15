options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: build_string_macro.sas
  *
  *  Summary: Build concatenate a string via macro loop iterations, removing 
  *           extra junk from the final loop.
  *
  *           See also quote_and_commaseparate.sas
  *
  *  Created: Tue 08 Mar 2005 17:01:34 (Bob Heckel)
  * Modified: Wed 29 Jul 2015 10:17:54 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source NOcenter sgen;

%let BYR=2003;
%let EYR=2005;

 /* Build normal undelimited string */
%macro BuildString;
  %local i;
  %global simpleyr;
  
  %let simpleyr=;

  /* Direction of loop is just to demo '%by' */
  %do i=&EYR %to &BYR %by -1;
    %let simpleyr=yr&i &simpleyr;
  %end;
%mend;
%BuildString

%put !!!&simpleyr;



 /* Build comma separated value string. */
%macro BuildCSVString;
  %local i;
  %global csvyr;
  
  %let csvyr=;

  %do i=&EYR %to &BYR %by -1;
    %let csvyr=yr&i, &csvyr;
  %end;

  /* Remove trailing comma */
  %let csvyr=%substr(%bquote(&csvyr), 1, %length(&csvyr)-1);
%mend;
%BuildCSVString

%put !!!&csvyr;



%macro BuildANDString;
  %local i;
  %global andyr;
  
  %let andyr=;

  %do i=&BYR %to &EYR;
    %let andyr=&andyr yr&i and;
  %end;

  /* Remove trailing 'AND' */
  %let andyr=%sysfunc(reverse(%substr(%sysfunc(reverse(&andyr)),5)));
%mend;
%BuildANDString

%put !!!&andyr;



 /* Good example of how to avoid SAS' maximum length of macrovariable errors */
proc sql NOprint;
  select count(distinct Patient_Last_Name) into :cntobs from subset_hp_npi where Patient_Last_Name ne '';
quit;
%put distinct Patient_Last_Name cntobs is &cntobs;

proc sql NOprint;
  select distinct Patient_Last_Name into :ITM1-:ITM%left(&cntobs) from subset_hp_npi where Patient_Last_Name ne '';
quit;

/* Create a quoted, comma-delimited list that is potentially longer than a
 * single INTO: macrovariable can hold.  Good for feeding to WHERE statements.
 * */
%macro buildlistCHAR;
  %do i=1 %to &cntobs;
    %if &i ne &cntobs %then %do;
%bquote('&&ITM&i',)
    %end;
    %else %do;
%bquote('&&ITM&i')
    %end;
  %end;
%mend;
data _null_; put "buildlistCHAR is %bquote(%buildlistCHAR)"; run; quit;
