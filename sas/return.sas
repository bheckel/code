options nosource;
 /*---------------------------------------------------------------------
  *     Name: return.sas
  *
  *  Summary: If there is an OUTPUT statement anywhere in the step then
  *           RETURN uses that one, otherwise it outputs and returns to
  *           top.
  *
  *  Created: Thu 23 Aug 2012 11:19:17 (Bob Heckel)
  *---------------------------------------------------------------------
  */

data survey;
  input x y;
  datalines;
21 25
20 22
7 17
  ;
run;

data t;
  set survey;
  if x eq 20 then return;  /* and implicitly output the obs to work.sample, unlike delete. */
  put 'using RETURN so this is not reached when x is 20 ' _ALL_;
run;
proc print data=_LAST_(obs=max) width=minimum; run;


endsas;
/* Same as (but worse than) a DELETE: ... if year < 2012 then delete;  ... */
...
if year < 2012 then return;
cost = foo * bar;
output;
...

