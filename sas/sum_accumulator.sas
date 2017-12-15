options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: sum_accumulator.sas
  *
  *  Summary: Demo of the unusual SAS sum accumulator statement.  Like the
  *           assignment statement, there is no keyword associated with it.
  *
  *           See also sum.sas
  *
  *  Created: Thu 10 Jun 2010 12:24:28 (Bob Heckel)
  * Modified: Fri 09 May 2014 12:39:22 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source NOcenter;

proc print data=sashelp.shoes(obs=10) width=minimum; run;

data t;
  retain cntr 1000 cntr3 0;  /* initialize the numeric if not zero */
  format cntr DOLLAR12.1;
  set sashelp.shoes(obs=10);

  if _N_ eq 5 then sales=.;  /* for null propagation testing */

  cntr+sales;           /* accumulator-style does not need a RETAIN if starting at 0 */
  cntr2 = cntr2+sales;  /* but this version fails w/o a RETAIN */
  /* Does NOT handle "missings propagate" gracefully like accumulator does */
  cntr3 = cntr3+sales;  /* fails w/o a RETAIN */
run;
proc print data=_LAST_(obs=max) width=minimum; run;
