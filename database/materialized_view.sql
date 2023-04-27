-- Created: 02-Oct-2019 (Bob Heckel)
-- Modified: 13-Feb-2023 (Bob Heckel)

---

SELECT owner, mview_name, last_refresh_date
  FROM all_mviews
 WHERE owner ='SETARS'
   AND mview_name in('MYMV')
  ORDER BY 2;

select owner, name, last_refresh, error, status, refresh_mode  
  from all_snapshots 
 where owner ='SETARS';

---

--https://oracle-base.com/articles/misc/materialized-views
SELECT * FROM SCOTT.emp;

CREATE MATERIALIZED VIEW scotts_emp_mv
  BUILD IMMEDIATE 
  REFRESH FORCE
  ON DEMAND
  AS
    SELECT * FROM SCOTT.emp;
    
BEGIN
  DBMS_STATS.gather_table_stats(
    ownname => 'ADMIN',
    tabname => 'SCOTTS_EMP_MV');
END;

SELECT * FROM scotts_emp_mv;

SELECT */*insert*/ FROM SCOTT.emp;

Insert into SCOTT.EMP (EMPNO,ENAME,JOB,MGR,HIREDATE,SAL,COMM,DEPTNO) values (999,'HECK','CLERK',7902,to_date('17-DEC-80 12.00.00','DD-MON-RR HH.MI.SS'),800,null,20);

exec DBMS_MVIEW.refresh('SCOTTS_EMP_MV');

drop MATERIALIZED VIEW emp_mv;
delete from scott.emp where empno=999;

---

-- https://asktom.oracle.com/pls/asktom/f?p=100:11:0::::P11_QUESTION_ID:9538465900346087401
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
