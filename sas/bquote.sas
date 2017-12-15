options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: bquote.sas
  *
  *  Summary: Demo of using %bquote to prevent Oregon's abbreviation OR from
  *           being mistaken as a mnemonic operator.
  *
  *           See file:///C:/bookshelf_sas/macro/z4bquote.htm
  *           "%BQUOTE and %NRBQUOTE do not require that you mark quotation
  *           marks and parentheses that do not have a match. However, the
  *           %QUOTE and %NRQUOTE functions do."
  *
  *
  *           If the value may contain an & or % use one of the NR functions.
  *
  *
  *           Use %STR() and %NRSTR() during compile time to mask character
  *           literals in your code, such as during an assignment statement:
  *
  *           %let myVar = %nrstr(SANFORD&SON);
  *
  *           Use %BQUOTE() and %NRBQUOTE() to mask the resolved values of
  *           variables during macro execution time. Such as:
  *
  *           %if %nrbquote(&myVar) = %nrstr(SANFORD&SON) %then %do;
  *
  *           In the above statement, the value of &myVar in the left operand
  *           is not known until runtime so we use one of the execution
  *           time functions. In addition, the value may contain an '&' that we
  *           do not want rescanned. However, for the right operand we want to
  *           quote SANFORD&SON during compile time since that value won't be
  *           changing.
  *
  *           Also see qry001.sas
  *
  *  Created: Tue 15 Apr 2003 08:42:48 (Bob Heckel)
  * Modified: Wed 01 Apr 2009 15:54:22 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source;

%global STCODE;
%let STCODE=OR;

 /*  In this case, %quote would also work but more robust to use %bquote. */
%macro OregonProtection;
  %if %bquote(&STCODE) eq %str(OR) %then
    %put !!! found &STCODE;
  %else
    %put !!! did not find &STCODE;
%mend OregonProtection;
%OregonProtection

 
 /* Better example: */
data _null_;
  /* Embedded single quote */
  store="Susan's Office Supplies";
  call symput('s', store);
run;

 /* Use %quote and you'll get:
  * "ERROR: A character operand was found in the %EVAL function or %IF 
  * condition..."
  */
%macro Readit;
  %if %bquote(&s) ne  %then 
    %put !!!! valid ***;
  %else 
    %put !!!! null value ***;
%mend Readit;
%Readit



%let ONE=123,456;
%let TWO=789,012;
%let THR=&ONE,&TWO;
%macro commaListsIn(c, d, e);
  %put !!!&c;
  %put !!!&d;
  %put !!!&e;
%mend;
 /* Must use bquote or it looks like "ERROR: More positional parameters found
  * than defined." to SAS.
  */
%commaListsIn(%bquote(&ONE), %bquote(&TWO), %bquote(&THR));

%put _all_;
