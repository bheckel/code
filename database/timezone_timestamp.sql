--Modified: 18-Jul-2022 (Bob Heckel)

create table t (
  a_ts         timestamp,
  non_local_ts timestamp with time zone,
  local_ts     timestamp with local time zone
);

insert into t values (
  timestamp'2017-01-01 00:00:00 +10:00',
  timestamp'2017-01-01 00:00:00 +10:00',
  timestamp'2017-01-01 00:00:00 +10:00'
);

select a_ts, non_local_ts, local_ts,
       systimestamp,
       to_timestamp(sysdate, 'DD-MON-YYYY HH24:MI:SS')
       sysdate,
       to_char(non_local_ts, 'DD-MON-YYYY HH24:MI:SS') x,
       to_char(sysdate, 'DD-MON-YYYY HH24:MI:SS') y
 from t;

select * from t;
/*
NON_LOCAL_TS preserves the exact value you store in it. But Oracle
normalizes the value before placing it in LOCAL_TS

NON_LOCAL_TS                        LOCAL_TS                        
01-JAN-2017 00.00.00.000000000 +10  31-DEC-2016 14.00.00.000000000
*/
drop table t;
