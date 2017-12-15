options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: str.sas
  *
  *  Summary: Demo of macro quoting.
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
  *  Created: Wed 01 Apr 2009 15:56:18 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source NOcenter;

 /* This is ok */
%let parens = %str(foo(saysbar));
%put &parens;


%macro m;
  %let foo='mystring';
  %let char1=%bquote(%substr(&foo,1,1));

  /* Must "mark" the single quote with a percent symbol */
  %if &char1 eq %str(%') %then
    %put !!!found a single quoted string;
%mend;
%m



%let ONE=123,456;
%let TWO=789,012;
%let THR=&ONE,&TWO;
%macro commasIn(c, d, e);
  %put !!!&c;
  %put !!!&d;
  %put !!!&e;
%mend;
 /* Must use bquote or it looks like "ERROR: More positional parameters found
  * than defined." to SAS.
  */
%commasIn(%bquote(&ONE), %bquote(&TWO), %bquote(&THR));

%put _all_;
