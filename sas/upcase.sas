options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: upcase.sas
  *
  *  Summary: Demo of uppercasing a string in a datastep without using a
  *           temporary variable.
  *
  *  Created: Mon 21 Jul 2003 10:44:16 (Bob Heckel)
  * Modified: Wed 19 Oct 2005 16:46:41 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source;

%let str=lowercase;

data _NULL_;
  put "!!! original: &str";

  x=upcase("&str");
  put x=;

  /* Works. */
  %put !!! converted: %upcase(&str);
run;


%macro mkupper(s);
  %let s=%upcase(&s);
  %put &s;
%mend;
%mkupper(helo);
