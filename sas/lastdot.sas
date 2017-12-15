options nosource;
 /*---------------------------------------------------------------------
  *     Name: lastdot.sas (also see firstdot.sas)
  *
  *  Summary: Demo of using last-dot and first-dot for subtotals
  *
              See also bygroup_processing.sas
  *
  *  Created: Mon 07 Oct 2002 15:04:21 (Bob Heckel)
  * Modified: Tue 08 Oct 2013 15:40:52 (Bob Heckel)
  *---------------------------------------------------------------------
  */
options source;

data t;
  infile cards;
  input branch $  earn1  earn2;
  cards;
a 2  3       /* first.branch 1  last.branch 0 */
a 20 30      /* first.branch 0  last.branch 0 */
a -22 33     /* first.branch 0  last.branch 1 */
c -9 34
c 23 34
c 24 36
b 11 22
b 34 45
  ;
run;
proc print data=_LAST_(obs=max) width=minimum; run;


 /* Mandatory for first dot and last dot */
proc sort; by branch; run;

data t2;
  set t;
  by branch;

  if first.branch then earn2tot=0;

  earn2tot+earn2;

  if last.branch;  /* we only need the final var as last.var even if we had a BY with multiple vars */
run;
proc print data=_LAST_(obs=max) width=minimum; sum earn2tot; run;



endsas;
  /* Have multiple filldates but want only the most recent fill of each patient's ndc */
  proc sort; by upid ndc filldate; run;
  data diab3;
    set diab2;
    by upid ndc;
    /* if pharmacypatientid='1538502' then put _all_; */
    if last.ndc then output;
  run;
