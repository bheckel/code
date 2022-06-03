
-- Modified: 08-Feb-2022 (Bob Heckel)
-- Execution plan. Query plan. SQL Tuning. Autotrace.
-- See also indexes.sql, devgym_create_toy_objects.sql

-- The B-tree traversal is the first power of indexing.
-- Clustering is the second power of indexing.

---

--  set pagesize 0
--ALTER SESSION SET statistics_level = all;  --not sure it matters
--SELECT s.osuser, O.OBJECT_NAME, S.SID, S.SERIAL#, P.SPID, S.PROGRAM, SQ.SQL_FULLTEXT, S.LOGON_TIME FROM V$LOCKED_OBJECT L, DBA_OBJECTS O, V$SESSION S, V$PROCESS P, V$SQL SQ WHERE L.OBJECT_ID = O.OBJECT_ID AND L.SESSION_ID = S.SID AND S.PADDR = P.ADDR AND S.SQL_ADDRESS = SQ.ADDRESS and osuser in('oradba','bheck','oracle','ecott') /* and SQL_FULLTEXT like 'UPDATE%_SS FIN%' ;-- 'UPDATE GIDB_COUNTRY_ISO_SS%'*/ order by 1; 
select SID, SERIAL#, USERNAME, STATUS, OSUSER, MACHINE, PROGRAM, SQL_ID, SQL_EXEC_START, PREV_SQL_ID, PREV_EXEC_START, LOGON_TIME, LAST_CALL_ET, CLIENT_IDENTIFIER, STATE, SERVICE_NAME, trunc(last_call_et/ 3600) as Hours from v$session where username is not null order by SQL_EXEC_START desc nulls last;
--SELECT * FROM v$sql WHERE sql_id='gvhhm0q3n6n2k';
--SELECT * FROM v$sql WHERE lower(sql_text) like '%photo%';
--Select plan_table_output From table(dbms_xplan.display_cursor('gvhhm0q3n6n2k',null,'allstats +cost +bytes'));
select * from table(dbms_xplan.display_cursor('gvhhm0q3n6n2k',format => 'IOSTATS LAST  +cost +bytes'));

---

-- Oracle indexing
-- See also https://blogs.oracle.com/sql/how-to-create-and-use-indexes-in-oracle-database

-- Use B-tree index where cardinality is high (many unique recs e.g. account
-- IDs) and column is usually part of a WHERE statement and DML is infrequent.
-- Use bitmap where cardinality is low (e.g. skewed grade scores at Harvard) and DML
-- is very infrequent (because it locks).
CREATE INDEX CONTACT_EMP_EVENT_CE_IX on CONTACT_EMPLOYEE_EVENT(CONTACT_EMPLOYEE_ID);
CREATE BITMAP INDEX CONTACT_EMP_EVENT_NE_IX on CONTACT_EMPLOYEE_EVENT(NEW_EVENT);
create index M_SUBCOMPGRP_FUNCTION_IX on M_SUBCOMP (LOWER(M_SUBCOMP_GROUP_NAME));


SELECT * FROM SYS.user_indexes WHERE table_name = 'EMAIL_MESSAGES';  -- does a B-tree (NORMAL) index exist for this table?

SELECT * FROM SYS.user_ind_statistics where table_name='EMAIL_MESSAGES';

SELECT * FROM email_messages WHERE created>sysdate-1;

SELECT * FROM v$sql WHERE sql_text like 'SELECT * FROM email_messages WHERE created%';  -- 5ax1juqfgxhnw
-- Explain Plan is hypothetical, this is actual:
SELECT * FROM v$sql_plan WHERE sql_id = '5ax1juqfgxhnw';  -- did index get used?: BY INDEX ROWID or RANGE SCAN etc.

select sum(email_messages_id) from email_messages;  -- FULL SCAN but no table access

---

-- Use ALTER SESSION SET statistics_level = all; if not using hint
select /*+ gather_plan_statistics */
       colour, count(*) 
from   bricks
group  by colour
order  by colour;

select *
from   table(dbms_xplan.display_cursor(format => 'ALLSTATS LAST'));
/*from   table(dbms_xplan.display_cursor(format => 'IOSTATS LAST'));*/
-- Probably best:
/*from   table(dbms_xplan.display_cursor(format => 'ALLSTATS +cost +bytes'));*/
/*
SQL_ID  f3z2z7vk5fj1d, child number 1
-------------------------------------
select         colour, count(*)  from   bricks group  by colour order  
by colour
 
Plan hash value: 2025330397
 
--------------------------------------------------------------------------------------------------------------------------
| Id  | Operation                  | Name   | Starts | E-Rows | A-Rows |   A-Time   | Buffers |  OMem |  1Mem | Used-Mem |
--------------------------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT           |        |      1 |        |      9 |00:00:00.01 |      42 |       |       |          |
|   1 |  SORT GROUP BY             |        |      1 |      9 |      9 |00:00:00.01 |      42 |  2048 |  2048 | 2048  (0)|
|   2 |   TABLE ACCESS STORAGE FULL| BRICKS |      1 |   2250 |   2250 |00:00:00.01 |      42 |  1025K|  1025K|          |
--------------------------------------------------------------------------------------------------------------------------
*/

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

-- Adapted from https://use-the-index-luke.com
-- 
-- Attributes of Explain Plan Operations:
-- 
-- There are two different ways databases use indexes to apply the WHERE clauses (predicates):
-- - ACCESS PREDICATES express the start and stop conditions for the leaf node traversal. They
--   define the scanned index range, which is hopefully narrow. An access predicate only reads 
--   rows where the condition is true.
-- 
-- - FILTER PREDICATES are applied during the leaf node traversal only. They don't
--   contribute to the start and stop conditions and do not narrow the scanned index range. It is
--   possible to modify an index and turn a filter predicate into an access predicate (e.g. by
--   changing indexed column order, etc). A filter predicate reads ALL the rows from the input, 
--   discarding those where the condition is false.
-- 
--   E.g.
--   SELECT first_name, last_name, subsidiary_id, phone_number
--     FROM employees
--    WHERE subsidiary_id = ?
--      AND UPPER(last_name) LIKE '%INA%';
--
--   A- Before adding index
--   --------------------------------------------------------------
--   |Id | Operation                   | Name       | Rows | Cost |
--   --------------------------------------------------------------
--   | 0 | SELECT STATEMENT            |            |   17 |  230 |
--   |*1 |  TABLE ACCESS BY INDEX ROWID| EMPLOYEES  |   17 |  230 |
--   |*2 |   INDEX RANGE SCAN          | EMPLOYEE_PK|  333 |    2 | <--- high Rows
--   --------------------------------------------------------------
--   
--   Predicate Information (identified by operation id):
--   ---------------------------------------------------
--      1 - filter(UPPER("LAST_NAME") LIKE '%INA%')
--      2 - access("SUBSIDIARY_ID"=TO_NUMBER(:A))
--   
--   B - Cover all columns from the WHERE clause - even if they do not narrow the scanned index range
--   CREATE INDEX empsubupnIX ON employees (subsidiary_id, UPPER(last_name));
--   --------------------------------------------------------------
--   |Id | Operation                   | Name       | Rows | Cost |
--   --------------------------------------------------------------
--   | 0 | SELECT STATEMENT            |            |   17 |   20 |
--   | 1 |  TABLE ACCESS BY INDEX ROWID| EMPLOYEES  |   17 |   20 |
--   |*2 |   INDEX RANGE SCAN          | EMPSUBUPNIX|   17 |    3 | <--- +1 because index is bigger due to adding last_name
--   --------------------------------------------------------------
--   
--   Predicate Information (identified by Operation Id):
--   ---------------------------------------------------
--      2 - access("SUBSIDIARY_ID"=TO_NUMBER(:A))
--          filter(UPPER("LAST_NAME") LIKE '%INA%')
-- 
--   According to the optimizer's estimate, the query ultimately matches 17 records.
--   The index scan in the first execution plan delivers 333 rows nevertheless. The
--   database must then load these 333 rows from the table to apply the LIKE filter
--   which reduces the result to 17 rows. In the second execution plan, the index
--   access does NOT deliver those rows in the first place so the database needs to
--   execute the TABLE ACCESS BY INDEX ROWID operation only 17 times.
-- 
--
-- Access Methods:
--
-- INDEX [ix name] UNIQUE SCAN 
-- Performs the B-tree traversal ONLY. The database uses this operation if a
-- unique constraint ensures that the search criteria will match no more than one
-- entry.  The database does not need to follow the index leaf nodes - it is enough to 
-- traverse the index tree thanks to the primary key or other constraint.  This operation
-- cannot deliver > 1 entry so it cannot trigger > 1 table access.  Always fast.
-- Only one row will be returned from the scan of a unique index. It will be used when there is an
-- equality predicate on a unique (B-tree) index or an index created as a result of a primary key constraint.
-- 
-- INDEX [ix name] RANGE SCAN 
-- Performs the B-tree traversal AND THEN follows the leaf node chain to find all
-- matching entries.  The biggest performance risk of an INDEX RANGE SCAN is the
-- leaf node traversal.  It is therefore the golden rule of indexing to keep the
-- scanned index range as small as possible (i.e. watch your ACCESS PREDICATES).  The so-called index 
-- FILTER PREDICATES often cause performance problems for an INDEX RANGE SCAN so keep the scanned 
-- index range as small as possible.  That usually means index for equality first, then for ranges.
-- Ideally the index "covers" the entire WHERE clause so that all filters are used as access predicates.
-- Oracle accesses adjacent index entries and then uses the ROWID values in the index to
-- retrieve the corresponding rows from the table. An index range scan can be bounded or unbounded. It will be used
-- when a statement has an equality predicate on a non-unique index key, or a non-equality or range predicate on a
-- unique index key. (=, <, >,LIKE if not on leading edge). Data is returned in the ascending order of index columns.
-- 
-- Notice that the table doesn't appear in the execution plan! This is also called a covering index.
-- For the optimizer to do this, at least one column must be NOT NULL. This is because Oracle excludes 
-- rows where all columns are NULL from (BTree) indexes. If all the columns allow nulls, the query 
-- could give incorrect results using an index as it would not return wholly NULL rows! E.g. WHERE color=...
-- AND weight=... so you'd have to do ALTER TABLE bricks MODIFY colour NOT NULL; (or weight) for Oracle 
-- to use the index.
-- 
-- TABLE ACCESS [tbl name] BY INDEX ROWID
-- Retrieves a row from the table using the ROWID retrieved from the preceding
-- index lookup access, e.g. INDEX RANGE SCAN.
-- The rowid of a row specifies the data file, the data block within that file, and the location
-- of the row within that block. Oracle first obtains the rowids either from a WHERE clause predicate or through an
-- index scan of one or more of the table's indexes. Oracle then locates each selected row in the table based on its
-- rowid and does a row-by-row access.
-- 
-- INDEX [ix name] FULL SCAN
-- Reads the entire index (all rows) in index order. Depending on various system
-- statistics, the database might perform this operation if it needs all rows in
-- index order—e.g., because of a corresponding order by clause.  Instead, the
-- optimizer might also use an INDEX FAST FULL SCAN and perform an additional sort operation.
-- A full index scan does not read every block in the index structure, contrary to what its name
-- suggests. An index full scan processes all of the leaf blocks of an index, but only enough of the branch blocks to find
-- the first leaf block. It is used when all of the columns necessary to satisfy the statement are in the index and it is
-- cheaper than scanning the table. It uses single block IOs.
--
-- INDEX SKIP SCAN 
-- Normally, in order for an index to be used, the prefix of the index key (leading edge of the index)
-- would be referenced in the query. However, if all the other columns in the index are referenced in the statement
-- except the first column, Oracle can do an index skip scan, to skip the first column of the index and use the rest of it.
-- This can be advantageous if there are few distinct values in the leading column of a concatenated index and many
-- distinct values in the non-leading key of the index.
-- 
-- INDEX [ix name] FAST FULL SCAN
-- Reads the entire index (all rows) as stored on the disk. This operation is
-- typically performed instead of a full table scan if all required columns are
-- available in the index. Similar to TABLE ACCESS FULL, the INDEX FAST FULL SCAN
-- can benefit from multi-block read operations.
-- This is an alternative to a full table scan when the index contains all the columns that are
-- needed for the query, and at least one column in the index key has the NOT NULL constraint. It cannot be used to
-- eliminate a sort operation, because the data access does not follow the index key. It will also read all of the blocks in
-- the index using multiblock reads, unlike a full index scan.

-- TABLE ACCESS [tbl name] STORAGE FULL
-- Also known as "full table scan". Reads the entire table (all rows AND COLUMNS!) as stored on the
-- disk. Although multi-block read operations improve the speed of a full table scan considerably
-- (especially if the results involve most of the table since an index lookup reads one block
-- after the other - the database does not know which block to read next until the current block
-- has been processed), it is still one of the most expensive operations. Besides high IO rates, a
-- full table scan must inspect ALL table rows so it can also consume a considerable amount of CPU
-- time.
-- Reads all rows from a table and filters out those that do not meet the where clause predicates. A
-- full table scan will use multi block IO (typically 1MB IOs). A full table scan is selected if a large 
-- portion of the rows in the table must be accessed, no indexes exist or the ones present can’t be 
-- used or if the cost is the lowest
--
--
-- Joins:
--
-- NESTED LOOPS JOIN
-- Joins two tables by fetching the result from one table and querying the other table for each 
-- row from the first. There can be many B-tree traversals when executing the inner query.
-- 
-- HASH JOIN
-- Loads the candidate records from one side (the smaller tbl) of the join into a hash
-- table that is then probed for each row from the other side of the join. Best to select only
-- minimal rows/columns from the hash table to keep it's Byte size small. Hash joins do not need indexes 
-- on the join predicates. They use the hash table instead. A hash join uses indexes only if the index 
-- supports the independent predicate(s).
-- 
-- SORT MERGE JOIN
-- Combines two sorted lists like a zipper. If both sides of the join
-- are presorted it can be efficient. There is absolute symmetry. The join order does not make any 
-- difference.
--
--
-- SORT ORDER BY
-- Sorts the result according to the order by clause. This operation needs large
-- amounts of memory to materialize the intermediate result (not pipelined).
-- 
-- SORT ORDER BY STOPKEY
-- Sorts a subset of the result according to the order by clause. Used for top-N
-- queries if pipelined execution is not possible.
-- 
-- SORT GROUP BY
-- Sorts the result set on the group by columns and aggregates the sorted result
-- in a second step. This operation needs large amounts of memory to materialize
-- the intermediate result set (not pipelined).
-- 
-- SORT GROUP BY NOSORT
-- Aggregates a presorted set according the group by clause. This operation does
-- not buffer the intermediate result: it is executed in a pipelined manner.
-- 
-- HASH GROUP BY
-- Groups the result using a hash table. This operation needs large amounts of
-- memory to materialize the intermediate result set (not pipelined). The output
-- is not ordered in any meaningful way.

---

CREATE INDEX tbl_idx ON tbl (date_column)

-- bad
SELECT COUNT(*)
  FROM tbl
 WHERE EXTRACT(YEAR FROM date_column) = 2017;

-- good
SELECT COUNT(*)
  FROM tbl
 WHERE date_column >= DATE'2017-01-01'
   AND date_column <  DATE'2018-01-01';


CREATE INDEX tbl_idx ON tbl (a, b)

-- bad  - this query can't use the index efficiently because indexes can only be used from left to right - it 
-- is like searching a telephone book by first name then last name
SELECT *
  FROM tbl
 WHERE b = 1;

-- good
CREATE INDEX tbl_idx ON tbl (b, a)
SELECT *
  FROM tbl
 WHERE a = 42
   AND b = 1;


CREATE INDEX tbl_idx ON tbl (a, date_column)

-- bad - database must look into the actual table
SELECT date_column, count(*)
  FROM tbl
 WHERE a = 42
   AND b = 1
 GROUP BY date_column;

-- good - index has all the columns so can be run as an index-only scan, no table accesses at all, the two 
-- ingredients that make an index lookup slow: (1) the table access, and (2) scanning a wide index range i.e.
-- not having TABLE ACCESS BY INDEX ROWID. If you select a single column that isn't in the index, the database 
-- cannot do an index-only scan. Same if you SELECT *.
SELECT date_column, count(*)
  FROM tbl
 WHERE a = 42
 GROUP BY date_column;

---

CREATE INDEX scale_slow ON scale_data (section, id1, id2);
/*
------------------------------------------------------
| Id | Operation         | Name       | Rows  | Cost |
------------------------------------------------------
|  0 | SELECT STATEMENT  |            |     1 |  972 |
|  1 |  SORT AGGREGATE   |            |     1 |      |
|* 2 |   INDEX RANGE SCAN| SCALE_SLOW |  3000 |  972 |
------------------------------------------------------

Predicate Information (identified by operation id):
   2 - access("SECTION"=TO_NUMBER(:A))
          filter("ID2"=TO_NUMBER(:B))
*/

CREATE INDEX scale_fast ON scale_data (section, id2, id1);
/*
------------------------------------------------------
| Id   Operation         | Name       | Rows  | Cost |
------------------------------------------------------
|  0 | SELECT STATEMENT  |            |     1 |   13 |
|  1 |  SORT AGGREGATE   |            |     1 |      |
|* 2 |   INDEX RANGE SCAN| SCALE_FAST |  3000 |   13 |
------------------------------------------------------

Predicate Information (identified by operation id):
   2 - access("SECTION"=TO_NUMBER(:A) AND "ID2"=TO_NUMBER(:B))
*/

---


create table x (a number(10) not null);

insert into x select level from dual connect by level < 500;

create index ix_x on x(a) compute statistics;

explain plan for select /*+ INDEX (x ix_x) */ * from x;

select * from table(dbms_xplan.display());

/*
-------------------------------------------------------------------------
| Id  | Operation        | Name | Rows  | Bytes | Cost (%CPU)| Time     |
-------------------------------------------------------------------------
|   0 | SELECT STATEMENT |      |   499 |  6487 |     1   (0)| 00:00:01 |
|   1 |  INDEX FULL SCAN | IX_X |   499 |  6487 |     1   (0)| 00:00:01 |
-------------------------------------------------------------------------

Note
-----
   - dynamic statistics used: dynamic sampling (level=2)
   - automatic DOP: Computed Degree of Parallelism is 1 because of parallel threshold

13 rows selected.
*/

---

-- Adapted: 04-Mar-2022 (Bob Heckel--Oracle Dev Gym)
create table flights (
  flight_id integer NOT NULL PRIMARY KEY,
  departure_airport_code varchar2(3) NOT NULL,
  destination_airport_code varchar2(3) NOT NULL,
  flight_datetime timestamp NOT NULL,
  airline varchar2(30) NOT NULL
);

create index flig_date_i on flights ( flight_datetime ); -- doesn' get used below

insert into flights
  with airports as (
    select 0 id, 'LHR' code from dual 
    union all
    select level id, dbms_random.string ( 'U', 3 ) code from dual
    CONNECT BY LEVEL <= 25
  ), dates as (
    select timestamp'2021-01-01 00:00:00' + numtodsinterval(level, 'day') dt
    --select sysdate + numtodsinterval(level, 'day') dt
      from   dual
   CONNECT BY LEVEL <= 365
  )
    select rownum, dep.code, dest.code, dt + numtodsinterval(mod(rownum, 24), 'hour'), 'SpeedyAir'
    from   airports dep
    join   airports dest
    on     dep.code <> dest.code
    join   dates
    on     ( mod(dep.id, 5) = mod(extract(day from dt ), 5) or
             mod(dest.id, 13) = mod(extract(day from dt), 13)
           )
    order  by dt;--62k rec

commit;

select /*+ gather_plan_statistics */destination_airport_code
  from  flights
 where  departure_airport_code = 'LHR'
   and  flight_datetime < timestamp '2021-01-05 00:00:00';
 
select * from table(dbms_xplan.display_cursor(format => 'IOSTATS LAST  +cost +bytes'));

create index fli1_i on flights ( departure_airport_code );--no effect
create index fli2_i on flights ( destination_airport_code );--no effect
create index fli3_i on flights ( departure_airport_code, flight_datetime );--ok
-- Including all the columns in your WHERE clause in an index can make your
-- queries faster. This is because it can find all the values it's looking for
-- in the index and only read these rows from the table.
--
-- Including all the columns in a query in an index can make it faster still.
-- This is because it enables the database to bypass the table entirely
create index fli4_i on flights ( departure_airport_code, flight_datetime, destination_airport_code );--BEST - a covering index
-- But in most cases it's better to stick with the two-column index. The
-- covering index only gives marginal gains over this. And the index is closely
-- tied to the query.  Selecting more columns, such as airline, means the
-- database has to read the table again. This erases the gains from the
-- covering index!

---

--  set pagesize 0
ALTER SESSION SET statistics_level = all;
select SID, SERIAL#, USERNAME, STATUS, OSUSER, MACHINE, PROGRAM, SQL_ID, SQL_EXEC_START, PREV_SQL_ID, PREV_EXEC_START, LOGON_TIME, LAST_CALL_ET, CLIENT_IDENTIFIER, STATE, SERVICE_NAME, trunc(last_call_et/ 3600) as Hours from v$session where username is not null order by SQL_EXEC_START desc nulls last;
SELECT * FROM v$sql WHERE sql_id='gvhhm0q3n6n2k';
SELECT * FROM v$sql WHERE lower(sql_text) like '%kmc%';
Select plan_table_output From table(dbms_xplan.display_cursor(null,null,'allstats +cost +bytes'));
