
create table t (
  non_local_ts timestamp with time zone,
  local_ts     timestamp with local time zone
);

insert into t values (
  timestamp'2017-01-01 00:00:00 +10:00',
  timestamp'2017-01-01 00:00:00 +10:00'
);

select * from t;
/*
NON_LOCAL_TS preserves the exact value you store in it. But Oracle
normalizes the value before placing it in LOCAL_TS

NON_LOCAL_TS                        LOCAL_TS                        
01-JAN-2017 00.00.00.000000000 +10  31-DEC-2016 14.00.00.000000000
*/
