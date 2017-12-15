options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: if_then_macro.sas
  *
  *  Summary: How to use if then blocks under SAS macro.
  *
  *           Use %IF to decide whether to GENERATE the code.
  *           Use IF to decide whether to EXECUTE the code.
  *
  *  Created: Wed 05 May 2004 13:30:53 (Bob Heckel)
  * Modified: Fri 14 Apr 2006 13:33:19 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source;

%macro m;
  %let x=1;
^=
  %if x ne 0 %then %do;
    %let limit=1;
  %end;
  %else %do;
    %let limit=;
  %end;

  %put _all_;
%mend;
%m

endsas;


%macro WhichEvt;
  %if &EVT eq NAT %then
    filename in "/data/dvsrtp/bhb6/data1/&fname" lrecl=1001;
  %else
    filename in "/data/dvsrtp/bhb6/data1/&fname" lrecl=701;
%mend WhichEvt;
%WhichEvt;

%let n=01;

%macro States;
  /* No semicolon at end of 'then'! */
  %if &n = 01 %then
    %do;
      %let s=AL;
      %let stname=Alabama;
      %put &stname;
    %end;
  /* No semicolon! */
  %else %if &n = 02 %then
    %do;
      %let s=AK;
      %let stname=Alaska;
      %put &stname;
    %end;
  /* No semicolon!  I SAID NO SEMICOLON!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! */
  %else
    %put error;
%mend States;
/*** %States ***/


%global CKME CKMET00;
%let CKME=42;
%let CKMETOO=;
%macro MoreComplicated;
  /* No '%' on the and!! */
  %if &CKME ne  and &CKMETOO eq   %then
    %put !!! CKME not empty: &CKME  but CKMET00 is empty: &CKMETOO; 
%mend MoreComplicated;
%MoreComplicated


%macro MoreComplicated;
  %local foo bar;
  %let foo=baz oom;

  /* No '%' sigil on eq ! */
  /* No quotes around bar ! */
  %if &foo eq bar OR &foo eq %str(baz oom) %then
    %put ok to do a macro put without a do-end wrap;
 
  data _null_;
    if _N_ eq 1 then
      do;
        /* The outer do-loop appears to require the inner, macro, do-loop's 
         * do / end wrap pair. 
         */
        %if &foo eq bar OR &foo eq %str(baz oom) %then
          %do;   /* <---mandatory */
            put "but not to do something in a SAS do-loop";
          %end;  /* <---mandatory */
      end;
  run;
%mend MoreComplicated;
%MoreComplicated
