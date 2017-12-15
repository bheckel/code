options nosource;
 /*---------------------------------------------------------------------------
  *     Name: append_macrovar.sas
  *
  *  Summary: Build a macrovariable string by appending to itself, either in a
  *           loop or via multiple calls.
  *
  *  Created: Fri 07 Mar 2003 10:07:39 (Bob Heckel)
  * Modified: Mon 28 Jul 2003 16:01:15 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source;

%global TOP;
%let TOP=3;

%macro Concatenate;
  %local i str;
  %do i=1 %to &TOP; 
    %let str=&str work.tmp&i;
  %end;
  %put !!! &str;
%mend Concatenate;
%Concatenate


%macro Concatenate2(inyr);
  %global setstatement;
  %let setstatement=&setstatement work.&inyr;
%mend Concatenate2;
%Concatenate2(2002)
%Concatenate2(2001)
%Concatenate2(2003)
%put !!! set &setstatement %str(;);



%let NUMPDS=2;
data final1;
 input x;
 cards;
1
 ;
run;
data final2;
 input x;
 cards;
2
 ;
run;

%macro BuildSetStmt;
  data work.allofthem;
    %let setstr=;
    %do f=1 %to &NUMPDS;
      %let setstr=&setstr final&f ;
    %end;
    set &setstr;
  run;
%mend;
%BuildSetStmt;
proc print data=work.allofthem; run;
