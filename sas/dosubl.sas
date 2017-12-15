options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: dosubl.sas
  *
  *  Summary: CALL EXECUTE vs. v9's DOSUBL
  *
  * DOSUBL differs from CALL EXECUTE in that CALL EXECUTE performs only
  * immediate execution on macro code. If that macro code expands to DATA and
  * PROC steps, that code is stacked to execute !!after!! the current DATA step
  * completes.
  *
  *  Adapted: Tue 08 Oct 2013 13:17:33 (Bob Heckel--SUGI 032-2013)
  *---------------------------------------------------------------------------
  */
options source NOcenter dsoptions=note2err;

%macro m(value);
  data _null_;
    call symput('xyz',"&value.");
  run;
%mend m;


%let xyz=q;
data _null_;
  call execute(' %m(a) ');
  xyz_value = symget('xyz');
  put xyz_value=;  /* q, not a as expected! */
run;
%put &xyz;  /* a */

%let xyz=q;
data _null_;
  rc = dosubl('%m(b)');
  xyz_value = symget('xyz');
  put xyz_value=;  /* b */
run;
%put &xyz;  /* b */
