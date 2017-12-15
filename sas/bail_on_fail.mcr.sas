
%macro m1;
  %put !!!ok1 &SYSCC;
%mend;
%macro m2;
  %put !!!ok2a &SYSCC;
  /* 0 */
/***  lkjsf;***/
  /* 4 */
  proc printt data=sashelp.class; run;
  %put !!!ok2b &SYSCC;
%mend;
%macro m3;
  %put !!!ok3 &SYSCC;
%mend;

%macro m;
 %m1;

 %m2;

 %if &SYSCC le 4 %then %do;
   %m3;
 %end;
 %else %do;
   %put ERROR: &SYSCC;
 %end;
%mend;
%m;
