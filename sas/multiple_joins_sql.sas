
proc sql;
  create table t1 as
  select a.pmapuserid, a.pmapusername, b.clientid, b.storeid, c.CountLogInsLast30DaysTotal, d.CountLogInsLast30DaysAtLeast1,
         d.CountLogInsLast30DaysAtLeast1/30 as PercentLogInsLast30DaysAtLeast1, "&measuredt"D as measure_enddt
  from ((pmapusers a left join pmapusers2 b on a.pmapuserid=b.pmapuserid) join loglast30 c on b.pmapuserid=c.pmapuserid) join atleast1 d on c.pmapuserid=d.pmapuserid
  ;
quit;
