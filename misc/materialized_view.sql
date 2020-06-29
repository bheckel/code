-- https://asktom.oracle.com/pls/asktom/f?p=100:11:0::::P11_QUESTION_ID:9538465900346087401
-- Modified: 02-Oct-2019 (Bob Heckel)

create materialized view mv as 
  select * from t;
  
create index i on mv ( c1 );

insert into t values ( 2 );

commit;

select * from mv;
/*
1
*/

exec dbms_mview.refresh( 'MV', 'C' );

select * from mv;
/*
1
2
*/

select table_name, index_name 
from   user_indexes
where  table_name in ( 'T', 'MV' );
/*
MV           I   
*/

---

create materialized view MYMV
  REFRESH FAST
  ON COMMIT
  as
  select h.region, h.office, h.patient, h.some_date,
         count(*) c,
         count(decode(hs.property, 'weight', hs.val, 0)) weight_cnt,
         count(decode(hs.property, 'height', hs.val, 0)) height_cnt,
         count(decode(hs.property, 'bp', hs.val, 0)) bp_cnt,
         sum(decode(hs.property, 'weight', hs.val, 0)) weight_val,
         sum(decode(hs.property, 'height', hs.val, 0)) height_val,
         sum(decode(hs.property, 'bp', hs.val, 0)) bp_val,
  from   patient h,
         patient_attrib hs
  where  h.region = hs.region
  and    h.office  = hs.office
  and    h.patient = hs.patient
  group by h.region, h.office, h.patient, h.some_date;
