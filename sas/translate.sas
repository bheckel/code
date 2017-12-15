options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: translate.sas
  *
  *  Summary: Translate all x into y.
  *
  *           translate('mother', 'f', 'm', 'a', 'o');  <---returns father
  *
  *           See also tranwrd.sas
  *
  *           In macro:
  *           %let product = %sysfunc(translate(foo_bar, ' ', '_'));
  *
  *           Better:
  *           %let reportlocationconverted=%sysfunc(prxchange(s/ /\\ /, -1, &reportlocation));
  *
  *  Created: Fri 09 May 2003 14:00:16 (Bob Heckel)
  * Modified: Mon 25 Feb 2008 09:57:08 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source;


data work.sample;
  input fname $ 1-10  lname $ 15-25  @30 numb 3.;
  array chars _CHARACTER_;
  do over chars;
    ***chars=translate(chars, 'XX', 'r');  /* 2 characters won't work! */
    /* Change all r to X */
    /* SAS weirdness as usual  <----   */
    chars = translate(chars, 'Xx', 'r');
  end;
  datalines;
mario         lemieux        123
ron           francis        123
jerry         garcia         123 
larry         wallo          345
  ;
run;
proc print; run;


endsas;
 /* or one var at a time: */
data work.sample;
  input fname $ 1-10  lname $ 15-25  @30 numb 3.;
  /* Note: bizarre reversed parameter ordering (and different from
   * tranwrd()).  
   */
  ***fname=translate(fname, 'X', 'r');
  fname=translate(fname, '', 'r');
  datalines;
mario         lemieux        123
ron           francis        123
jerry         garcia         123 
larry         wallo          345
  ;
run;
