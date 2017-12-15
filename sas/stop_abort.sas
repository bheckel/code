options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: stop_abort.sas
  *
  *  Summary: Demo of stopping the current obs from writing and stopping 
  *           further stepping vs. stopping the whole program.
  *
  *  Created: Wed 22 Aug 2012 14:27:38 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source NOcenter dsoptions=note2err;


data t;
  infile CARDS;
  input a b c;
  cards;
1 2 3
4 5 6
7 . 9
. . 0
1 1 1
  ;
run;
proc print data=_LAST_(obs=max) width=minimum; run;

data t2;
  set t;
  if nmiss(of a--c) gt 1 then stop;
run;
proc print data=_LAST_(obs=max) width=minimum; run;


data t2;
  set t;
  if nmiss(of a--c) gt 1 then abort;
run;
proc print data=_LAST_(obs=max) width=minimum; run;

