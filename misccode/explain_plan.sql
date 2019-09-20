
-- Created:  Thu 30-Jul-2019 (Bob Heckel)
-- Modified: Thu 19-Sep-2019 (Bob Heckel)

---

-- Oracle indexing
-- See also https://blogs.oracle.com/sql/how-to-create-and-use-indexes-in-oracle-database

-- Use B-tree index where cardinality is high (many unique recs e.g. account
-- IDs) and column is usually part of a WHERE statement and DML is infrequent.
-- Use bitmap where cardinality is low (e.g. skewed grade scores at Harvard) and DML
-- is very infrequent (because it locks).
CREATE INDEX CONTACT_EMP_EVENT_CE_IX on CONTACT_EMPLOYEE_EVENT(CONTACT_EMPLOYEE_ID);
CREATE INDEX CONTACT_EMP_EVENT_EV_IX on CONTACT_EMPLOYEE_EVENT(EVENT_ID);
CREATE BITMAP INDEX CONTACT_EMP_EVENT_NE_IX on CONTACT_EMPLOYEE_EVENT(NEW_EVENT);
create index M_SUBCOMPGRP_FUNCTION_IX on M_SUBCOMP (LOWER(M_SUBCOMP_GROUP_NAME));


SELECT * FROM SYS.user_indexes WHERE table_name = 'EMAIL_MESSAGES';  -- does B-tree (NORMAL) index exist?

SELECT * FROM SYS.user_ind_statistics where table_name='EMAIL_MESSAGES';

SELECT * FROM email_messages WHERE created>sysdate-1;

SELECT * FROM v$sql WHERE sql_text like 'SELECT * FROM email_messages WHERE created%';  -- 5ax1juqfgxhnw

-- Explain Plan is hypothetical, this is actual:
SELECT * FROM v$sql_plan WHERE sql_id = '5ax1juqfgxhnw';  -- did index get used?: BY INDEX ROWID or RANGE SCAN etc.

select sum(email_messages_id) from email_messages;  -- FULL SCAN but no table access

---

EXPLAIN PLAN FOR
  SELECT *
  FROM email_messages t 
--WHERE  t.execute_time BETWEEN to_date('2019-01-16:09:00','YYYY-MM-DD:HH24:MI') AND to_date('2019-01-16:11:00','YYYY-MM-DD:HH24:MI'); --debug 
  WHERE t.actual_updated > (SYSTIMESTAMP - INTERVAL '444' minute);
 
select plan_table_output
--from table(dbms_xplan.display('plan_table',null,'basic'));
--from table(dbms_xplan.display('plan_table',null,'basic +predicate +cost'));
from table(dbms_xplan.display('plan_table',null,'typical'));

ROLLBACK;

---

-- http://rwijk.blogspot.com/2018/02/filter-predicates-with-nvl-on-mandatory.html
set echo on
set serveroutput off
column description format a40 truncate
select * from v$version
/
create table robtest
as
select level id
      , ceil(level/10000)  code1
      , ceil(level/1000)   code2
      , ceil(level/100)    code3
      , mod(level/100,100) code4
      , lpad('*',1000,'*') description
   from dual
connect by level <= 100000
/
alter table robtest add constraint robtest_uk unique (code1,code2,code3,code4)
/
exec dbms_stats.gather_table_stats(user,'robtest',cascade=>true)
set autotrace on
select *
  from robtest
where code1 = 1
   and code2 = 1
   and code3 = 1
   and code4 = 1
/
select *
  from robtest
where nvl(code1,-1) = 1
   and nvl(code2,-1) = 1
   and nvl(code3,-1) = 1
   and nvl(code4,-1) = 1
/
alter table robtest modify code1 constraint nn1 not null
/
alter table robtest modify code2 constraint nn2 not null
/
alter table robtest modify code3 constraint nn3 not null
/
alter table robtest modify code4 constraint nn4 not null
/
select *
  from robtest
where nvl(code1,-1) = 1
   and nvl(code2,-1) = 1
   and nvl(code3,-1) = 1
   and nvl(code4,-1) = 1
/
set autotrace off
set echo off
drop table robtest purge
/

---

-- https://use-the-index-luke.com
-- 
-- Attributes of Explain Plan Operations:
-- 
-- There are two different ways databases use indexes to apply the where clauses (predicates):
-- - ACCESS predicates express the start and stop conditions for the leaf node traversal.
-- 
-- - FILTER predicates are applied during the leaf node traversal only. They don't
--   contribute to the start and stop conditions and do not narrow the scanned range.
-- 
-- --------------------------------------------------------------
-- |Id | Operation                   | Name       | Rows | Cost |
-- --------------------------------------------------------------
-- | 0 | SELECT STATEMENT            |            |   17 |  230 |
-- |*1 |  TABLE ACCESS BY INDEX ROWID| EMPLOYEES  |   17 |  230 |
-- |*2 |   INDEX RANGE SCAN          | EMPLOYEE_PK|  333 |    2 |
-- --------------------------------------------------------------
-- 
-- Predicate Information (identified by operation id):
-- ---------------------------------------------------
--    1 - filter(UPPER("LAST_NAME") LIKE '%INA%')
--    2 - access("SUBSIDIARY_ID"=TO_NUMBER(:A))
-- 
-- 
-- CREATE INDEX empsubupnam ON employees (subsidiary_id, UPPER(last_name))
-- 
-- --------------------------------------------------------------
-- |Id | Operation                   | Name       | Rows | Cost |
-- --------------------------------------------------------------
-- | 0 | SELECT STATEMENT            |            |   17 |   20 |
-- | 1 |  TABLE ACCESS BY INDEX ROWID| EMPLOYEES  |   17 |   20 |
-- |*2 |   INDEX RANGE SCAN          | EMPSUBUPNAM|   17 |    3 | <--- +1 index is bigger due to adding last_name
-- --------------------------------------------------------------
-- 
-- Predicate Information (identified by operation id):
-- ---------------------------------------------------
--    2 - access("SUBSIDIARY_ID"=TO_NUMBER(:A))
--        filter(UPPER("LAST_NAME") LIKE '%INA%')
-- 
-- 
-- According to the optimizer's estimate, the query ultimately matches 17 records.
-- The index scan in the first execution plan delivers 333 rows nevertheless. The
-- database must then load these 333 rows from the table to apply the LIKE filter
-- which reduces the result to 17 rows. In the second execution plan, the index
-- access does not deliver those rows in the first place so the database needs to
-- execute the TABLE ACCESS BY INDEX ROWID operation only 17 times.
-- 
-- The biggest performance risk of an INDEX RANGE SCAN is the leaf node traversal.
-- It is therefore the golden rule of indexing to keep the scanned index range as
-- small as possible.
