options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: double_triple_ampersand_resolution.sas 
  *
  *  Summary: Demo of twisting Macro into a (more) contorted mess.
  *
  *  Created: Thu 13 Mar 2003 13:56:24 (Bob Heckel)
  * Modified: Wed 01 Apr 2009 13:09:32 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source;

 /* Macro resolution rules:
  * 1) && resolves to & ("SYMBOLGEN:  && resolves to &.")
  * 2) Each token is handled independently
  *
  * So we'd never need > 3 ampersands
  */
%let A = C;
%let B = A;
%put !!! &&B (A is not what we were expecting, expected C);
%put !!! &&&B (takes 3 ampersands to get C);



 /* To Resolve &&var&i using the rules above:
  * 1) && is the first token and resolves to &
  * 2) var&i is the next token and resolves to var1, var2, etc
  * This leaves &var1, &var2, etc which is rescanned and resolved.
  */
%macro Simple;
  %local i y1 y2 y3;

  %let y1=2001;
  %let y2=2002;
  %let y3=2003;

  %do i=1 %to 3;
    %put !!! year is: &&y&i;
    %put !!! be careful -- to get year.BOB must use two stop characters, aka dots: &&y&i...BOB;
  %end;
%mend Simple;
%Simple



 /* Hash-like */
%macro Sugi(city);
  %let ORLANDO=27;
  %let SEATTLE=28;
  %let MONTREAL=29;
 
  /* Must use 3 ampersands!     */
  /*                   _______  */
  %put &city held SUGI &&&city;
%mend;
%Sugi(ORLANDO);



 /* Much more convoluted example: */

%let the_sexmax=6;
%let sex1=01;
%let sex3=03;
%let sex4=;
%let sex5=05;

 /* "Return" e.g. &sexrequested which holds a pipe-delimited string of the
  * checkbox values checked by the user.
  */
%macro VarRequested(t);
  %global &t.request;
  %let &t.request=;
  %do i=1 %to &&the_&t.max;
    /* Protect against undefined macrovars. */
    %global &t.&i;
    /* Create pipe delimited string by concatenation. */
    %let &&t.request=&&&t.request|&&&t.&i;
  %end;
  %put !!!1 &&&t.request;
%mend VarRequested;
 /* TODO raise error if 1 (no boxes ckd) */
%VarRequested(sex)

%put !!!2 &sexrequest;
