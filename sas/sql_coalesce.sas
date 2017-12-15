options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: sql_coalesce.sas
  *
  *  Summary: Demo of using the coalesce statement in SAS SQL.  It scans the
  *           list of vars from left to right and returns the first non-NULL
  *           value in the list.  Good for sparsely populated vars like SSN,
  *           weight, etc. or on joined tables with the same var names. Or
  *           overlaying older data as a default where newer data doesn't 
  *           exist.
  *
  *  Created: Thu 03 Apr 2003 19:42:02 (Bob Heckel)
  * Modified: Thu 09 May 2013 12:36:25 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source;

data work.sched;
   input flight 3.  +5  dt date7.  +2  dest $3.  +3  idnum 4.;
   informat dt date7.;
   /* Make date human here, can't do it in proc sql. */
   format dt date7.;
   cards;
132     01MAR94  YYZ   1739
132     01MAR94  YYZ   1478
        01MAR94  YYZ        
132     01MAR94  YYZ   1390
        01MAR94  YYZ   1983
622     02MAR94  FRA   1124
271     07MAR94  PAR   1410
        07MAR94  PAR   1777
622     07MAR94  FRA   1433
622     07MAR94  FRA   1352
;
run;
title "ds:&SYSDSN";proc print data=_LAST_(obs=max) width=minimum heading=H; run;title;


title 'First available';
proc sql;
  /*                         default must be numeric like the other two */
  /*                                 --                                 */
  select dt, coalesce(flight, idnum, 0) as flight
  from work.sched;
quit;
