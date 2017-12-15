libname l 'u:/';

proc sql;
  /* This group has an extreme value */
  create table t as
  select *
  from l.junkuhoh
  where sampid in (
    select distinct sampid
    from l.junkuhoh
    group by SampId, SampName, _resrep
    having max(_resrep) gt 1
    )
  ;
  /* These don't */
  create table t2 as
  select *
  from l.junkuhoh
  where sampid not in (
    select distinct sampid
    from l.junkuhoh
    group by SampId, SampName, _resrep
    having max(_resrep) gt 1
    )
  ;
quit;
/***proc print data=_LAST_(obs=max) width=minimum; run;***/

 /* Fuse them back together */
data t3;
  set t t2;
run;
proc sort data=t3; by sampid sampname _resrep device;run;
proc compare base=l.junkuhoh compare=t3;run;
