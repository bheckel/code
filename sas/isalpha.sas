
data t;
/***  input c $CHAR2.;***/
  input c $2.;
  cards;
a
 b
C
@
d
  ;
run;
proc print data=_LAST_(obs=max) width=minimum; run;

 /* Single character check */
data t2;
  set t;
  if upcase(c) ge 'A' and upcase(c) le 'Z';
run;
proc print data=_LAST_(obs=max) width=minimum; run;

 /* See verify.sas for full words */
