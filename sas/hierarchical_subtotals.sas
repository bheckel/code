options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: hierarchical_subtotals.sas
  *
  *  Summary: Hierarchical subtotals of data.  Three digit codes must count
  *           themselves PLUS any 4 digit codes that rollup to them.
  *           If orphans don't have a 3 digit toplevel, must create one which
  *           holds the total count of orphans.
  *
  *           Parent - child relationships.
  *
  *           Used in UCSELECT.
  *
  *  Created: Tue 20 May 2003 10:09:54 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source;

 /* We're assuming the infile has been sorted. */
data tmp;
  retain prefix;
  infile cards TRUNCOVER;
  /* e.g.  A04       A047   */
  length prefix $ 4  sub $ 4;
  input cause $;
  /* We have a new cluster. */
  if length(cause) eq 3 then
    prefix = cause;
  /* We have a sub-code. */
  else if substr(cause, 1, 3) = prefix then
    sub = cause;
  /* We have a 4 digit without a toplevel 3 parent.  Can't create a parent
   * here b/c it will inflate the total incorrectly. 
   */
  else
    prefix = cause;
  cards;
A04
A047
A047
A49
A49
A490
A490
A490
A499
B16
B18
C122
C122
C123
  ;
run;

 /* Create parents for orphans (e.g. C12 doesn't exist), if any. */
data fours;
  set tmp (keep= cause);
  if length(cause) eq 4;
run;

data parented;
  set fours;
  artificial = substr(cause, 1, 3);
run;

 /* Raw pre-count. */
proc sql;
  create table tmp2 as
  select prefix, count(prefix) as cp, sub, count(sub) as cs 
  from tmp
  group by prefix, sub
  order by prefix
  ;
quit;

 /* Count the sublevels. */
proc sql;
  create table subleveltot as
  select sub as icd, cs as totcnt
  from tmp2
  where cs ne 0
  ;
quit;

 /* Count the toplevels. */
proc sql;
  create table topleveltot as
  select prefix as icd, sum(cp) as totcnt
  from tmp2
  group by prefix
  order by prefix
  ;
quit;

data rawfinished;
  merge topleveltot subleveltot;
  by icd;
run;
proc sort data=rawfinished;
  by icd;
run;

 /* Now must create parents if needed. */
data addparents (drop= cause);
  merge parented (rename= artificial=icd) rawfinished;
  by icd;
  /* We have a 4 digit sublevel that has no 3 digit parent. */
  if totcnt eq . then 
    do;
      newparent+1;
    end;
  else newparent=0;
run;
proc sort;
  by icd;
run;

data addparents;
  set addparents;
  if newparent ne 0 then
    totcnt = newparent;
run;

data subtotalled (drop= newparent);
  set addparents;
  by icd;
  if last.icd;
run;
proc print; run;
