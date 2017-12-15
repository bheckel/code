options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: sql_update.sas
  *
  *  Summary: Demo of using the update statement in SAS SQL.
  *
  *           See also update_via_lookup.sas for complex dup key COALESCE
  *
  *  Created: Thu 03 Apr 2003 19:42:02 (Bob Heckel)
  * Modified: Fri 10 May 2013 13:39:07 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source;

data work.sched;
  input flight 3.  +5  dt date7.  +2  dest $3.  +3  cost 4.;
  informat dt date7.;
  /* Make date human-readable */
  format dt date7.;
  cards;
132     01MAR94  YYZ   1739
132     01MAR94  YYZ   1478
        01MAR94  YYZ        
132     01MAR94  YYZ   1390
622     02MAR94  FRA   1124
  ;
run;
proc print data=work.sched; run;


 /* For comparison */
title 'datastep (same)';
data sched2;
  set sched;
  if flight eq 132 then
    cost+100000;
run;
proc print data=sched2; run;


title 'SQL (same)';
proc sql;
  update sched
  set cost = cost + 100000
  where flight = 132
  ;
quit;
proc print data=work.sched; run;


title 'complex logic updates';
proc sql;
  update sched
  set cost = case
               when dest eq 'YYZ' then cost-1
               when dest eq 'FRA' then cost+1
               else cost
             end;

  update sched
  set cost = case
               when cost gt 1450 then cost+5
               else                   cost=0
             end;
  ;
quit;
proc print data=sched(obs=max) width=minimum; run;


data lookup;
  input flight 3.  +5  dt date7.  +2  dest $3.  +3  cost 4.;
  informat dt date7.;
  cards;
132     01MAR94  abc   1739
  ;
run;

title 'complex lookup update';
proc sql;
  update sched as a
  set dest = (select dest from lookup as b where a.flight=b.flight)
  where a.flight in (select flight from lookup)
  ;
quit;
proc print data=sched(obs=max) width=minimum; run;
