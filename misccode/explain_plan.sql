
-- Created: 30-Jul-19 (Bob Heckel)
-- Modified: 31-Jul-19 (Bob Heckel) 

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
