options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: global.sas
  *
  *  Summary: Demo of scope.
  *
  *  Created: Wed 15 Sep 2004 10:28:03 (Bob Heckel)
  * Modified: Mon 13 Apr 2009 12:41:41 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source NOcenter mlogic mprint sgen;

 /* These two don't differ in any way below */
%global DECLAREDGLOBAL; %let DECLAREDGLOBAL=1;
%let UNDECLAREDGLOBAL=1;

%macro m;
  %do i=1 %to 3;
    %global MYMVAR&i;
    %let MYMVAR&i=foo&i;

    %local MYLOCMVAR&i; 
    %let MYLOCMVAR&i=bar&i;
  %end;

  %put MYLOCMVAR2: &MYLOCMVAR2;

  %put DECLAREDGLOBAL: &DECLAREDGLOBAL;
  %let DECLAREDGLOBAL=2;  /* and stays '2' in INCLUDEd file */

  %let UNDECLAREDGLOBAL=2;  /* and stays '2' in INCLUDEd file */
  %put UNDECLAREDGLOBAL: &UNDECLAREDGLOBAL;
%mend;
%m

%put _USER_;

%include 't.sas';


endsas;
t.sas:
%put !!!! in t;
%put _all_;
