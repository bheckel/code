options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: sql_aggregates.sas
  *
  *  Summary: Demo of using aggregate functions in SAS SQL.
  *
  *  Created: Sat 05 Apr 2003 10:09:11 (Bob Heckel)
  * Modified: Thu 21 Apr 2005 15:24:41 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source;

data work.sched;
   input flight 3.  +5  dt date7.  +2  dest $3.  +3  idnum 4.;
   informat dt DATE7.;
   format dt DATE7.;
   cards;
132     01MAR94  YYZ   1
132     01MAR94  YYZ   2
        07MAR94  PAR   1
622     07MAR94  FRA   3
622     07MAR94  FRA   3
622     07MAR94  FRA   2
;
run;


proc sql;
  select sum(idnum)
  from work.sched;
quit;


proc sql;
  select sum(distinct idnum)
  from work.sched;
quit;


proc sql;
  select count(dt)
  from work.sched;
quit;


 /************/

proc sql;
  select count(distinct dt)
  from work.sched;
quit;

proc print data=sched; run;
proc sql;
  select count(dest) into :CNT
  from sched
  where dest eq 'FRA'
  ;
quit;
%put !!!&CNT;

 /************/


proc sql;
 /***   select flight, idnum * 500 as uselessmultiplication ***/
  select flight, idnum * 500 as uselessmultiplication FORMAT=DOLLAR8.2
  from work.sched;
quit;

