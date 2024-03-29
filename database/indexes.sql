--  Created: 28-May-2020 (Bob Heckel)
-- Modified: 04-Mar-2022 (Bob Heckel)
-- see also explain_plan.sql, ddl.sql

---

-- Verify index is actually used

create index sgix on z_tmp (salesgroup);

alter index sgix monitoring usage;

select index_name, table_name, used from v$object_usage; -- YES

select distinct salesgroup from z_tmp;

alter index sgix nomonitoring usage;

---

select index_name, table_name, used from v$object_usage;--null
alter index KRB_HC_IN_CIX monitoring usage;
select index_name, table_name, used from v$object_usage;--not null if index being used
alter index KRB_HC_IN_CIX nomonitoring usage;
...

--or 

select index_name, table_name, used from v$object_usage;--not null if index being used

--  set serveroutput on
BEGIN 
  FOR r IN ( select index_name from user_indexes where TABLE_NAME = 'MKC_REVENUE_FULL_BOB' and index_name not like 'SYS_%' ) LOOP 
    dbms_output.put_line(r.index_name);
    execute immediate 'alter index "' || r.index_name || '" monitoring usage';
    /*execute immediate 'alter index "' || r.index_name || '" nomonitoring usage';*/
  END LOOP; 
END;

select index_name, table_name, used from v$object_usage;--not null if index is being used

---

-- Determine index fragmentation - bad if ratio >10
analyze index sgix validate structure;
select DECODE(LF_ROWS, 0, 0, ROUND((DEL_LF_ROWS/LF_ROWS)*100,2)) RATIO, HEIGHT, LF_BLKS, LF_ROWS FROM INDEX_STATS I;

alter index sgix rebuild online;

drop index sgix;

create index sgix on z_tmp (salesgroup) invisible;

select distinct salesgroup from z_tmp;

select index_name, table_name, used from v$object_usage; -- null

alter index sgix visible;

--  set serverout on size 100000
declare
  a number; b number; c number; d number;
begin
  for r in ( select distinct uic.INDEX_NAME ix from user_ind_columns uic where uic.TABLE_NAME = 'MKC_REVENUE_FULL' ) loop
     --DBMS_OUTPUT.put_line(r.ix); 
    execute immediate 'ANALYZE index ' || r.ix || ' VALIDATE STRUCTURE';
    
    SELECT DECODE(LF_ROWS, 0, 0, ROUND((DEL_LF_ROWS/LF_ROWS)*100,2)) RATIO, HEIGHT, LF_BLKS, LF_ROWS
      into a, b, c, d
      FROM INDEX_STATS I;
    
    DBMS_OUTPUT.put_line(r.ix || ' a:'||a || ' b:'||b || ' c:'||c || ' d:'||d);
  end loop;
end;

---

--ORA-08102: index key not found, obj# 5438124, file 5, block 67807674 (2)
select substr(object_name,1,30), object_type from user_objects where object_id = 5438124;--CONTACT_MIDDLENAME_LIST_IX
-- rebuild index
ALTER INDEX CONTACT_MIDDLENAME_LIST_IX rebuild online tablespace SE_01;

---

CREATE TABLE employees (
   employee_id   NUMBER         NOT NULL,
   first_name    VARCHAR2(1000) NOT NULL,
   last_name     VARCHAR2(1000) NOT NULL,
   date_of_birth DATE           NOT NULL,
   phone_number  VARCHAR2(1000) NOT NULL,
   CONSTRAINT employees_pk PRIMARY KEY (employee_id)
);

-- The database automatically creates an index for the primary key. That means there is an index on the EMPLOYEE_ID column, 
-- even though there is no CREATE INDEX statement like this one:
CREATE UNIQUE INDEX employees_pk ON employees (employee_id);

---

with inds as (    
    select substr(    
             index_name, instr(index_name, '_') + 1,     
             instr(index_name, '_', 1, 2) - instr(index_name, '_') - 1    
           ) col, leaf_blocks,    
           index_type    
    from   user_indexes    
)    
  select * from inds    
  pivot (     
    sum(leaf_blocks)     
    for index_type in ('NORMAL' btree, 'BITMAP' bitmap)    
  )

---

CREATE INDEX sales_idx ON sales_temp(prod_id,cust_id,time_id,amount_sold);
 
SELECT BYTES/(1024*1024) mb FROM user_segments WHERE  segment_name = 'SALES_IDX';
 
SELECT index_name, index_type, leaf_blocks, compression FROM user_indexes WHERE index_name = 'SALES_IDX';
 
SELECT prod_id,cust_id,time_id FROM sales_temp WHERE prod_id = 13; 
 
ALTER INDEX sales_idx REBUILD COMPRESS 1;
 
ALTER INDEX sales_idx REBUILD COMPRESS 2;
 
ALTER INDEX sales_idx REBUILD COMPRESS 3;
 
ALTER INDEX sales_idx REBUILD COMPRESS;
 
ALTER INDEX sales_idx REBUILD COMPRESS ADVANCED LOW;
 
ALTER INDEX sales_idx REBUILD COMPRESS ADVANCED HIGH;
 
DROP INDEX sales_idx;
CREATE BITMAP INDEX sales_idx ON sales_temp(prod_id,cust_id,time_id,amount_sold);
 
DROP INDEX sales_idx;
CREATE BITMAP INDEX sales_idx ON sales_temp(prod_id,cust_id,time_id,amount_sold) COMPRESS; -- FAIL
 
DROP INDEX sales_idx;
CREATE INDEX sales_idx ON sales_temp(prod_id) COMPRESS;

-- Create function-based index FBI
create index note_actupd_fbix on note_base ( trunc(actual_updated) );

---

alter session set star_transformation_enabled = true;
 
select /*+ star_transformation fact(s)*/
c.cust_last_name,s.amount_sold, p.prod_name, c2.channel_desc
from sales s, products p, customers c, channels c2
where s.prod_id = p.prod_id
and s.cust_id = c.cust_id
and s.channel_id = c2.channel_id
and p.prod_id < 100
and c2.channel_id = 2
and c.cust_postal_code = 52773;

---

-- View contents of an index (including function based indexes)

-- Find it
SELECT i.table_owner, i.table_name, i.index_name, i.uniqueness, c.column_name, f.column_expression
FROM      all_indexes i
LEFT JOIN all_ind_columns c
 ON   i.index_name      = c.index_name
 AND  i.owner           = c.index_owner
LEFT JOIN all_ind_expressions f
 ON   c.index_owner     = f.index_owner
 AND  c.index_name      = f.index_name
 AND  c.table_owner     = f.table_owner
 AND  c.table_name      = f.table_name
 AND  c.column_position = f.column_position
    i.index_name='ACC_TEAM_ASSIGNMENT_U_ACTIV_IX'
ORDER BY i.table_owner, i.table_name, i.index_name, c.column_position;

-- Run it
select DECODE(TO_CHAR("ACCOUNT_SITE_ID"),NULL,'A'||TO_CHAR("ACCOUNT_TEAM_ASSIGNMENT_ID"),'S'||TO_CHAR("ACCOUNT_SITE_ID"))||'-'||TO_CHAR("ASSIGNMENT_ACTIVE")
from account_team_assign_all;

---

-- Ignore INDEX using a hint:
SELECT /*+ NO_INDEX(EMPLOYEES EMPLOYEES_PK) */ first_name, last_name, subsidiary_id, phone_number
  FROM employees
 WHERE last_name  = 'WINAND'
   AND subsidiary_id = 30;
/*
----------------------------------------------------
| Id | Operation         | Name      | Rows | Cost |
----------------------------------------------------
|  0 | SELECT STATEMENT  |           |    1 |  477 |
|* 1 |  TABLE ACCESS FULL| EMPLOYEES |    1 |  477 |
----------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------
   1 - filter("LAST_NAME"='WINAND' AND "SUBSIDIARY_ID"=30)
*/

---

-- All columns that are a foreign key MUST have an index on them, otherwise, when Oracle validates the value for the 
-- index, it is a HUGE performance hit(still true in 2022??)
select uc.constraint_name, ucc.table_name, ucc.column_name--,'CREATE INDEX ' || ucc.table_name || 'XX_IX on ' || ucc.table_name|| '(' || ucc.column_name || ');' index_create
  from user_constraints uc, user_cons_columns ucc
 where uc.constraint_name = ucc.constraint_name
   and uc.constraint_type = 'R' -- FK
   and NOT exists (select 1
                     from user_ind_columns uic
                    where uic.table_name = uc.table_name
                      and uic.column_name = ucc.column_name);

---

-- If you know that there is always a leading wild card, you can obfuscate the
-- LIKE condition intentionally so that the optimizer can no longer consider the index on LAST_NAME
SELECT last_name, first_name, employee_id
  FROM employees
 WHERE subsidiary_id = ?
   AND last_name || '' LIKE ?

---

-- Each column's index for most tables:
select distinct utc.TABLE_NAME, uic.COLUMN_NAME, uic.INDEX_NAME
	from user_objects ut, user_tab_cols utc, user_ind_columns uic
 where ut.OBJECT_TYPE = 'TABLE'
	 and ut.OBJECT_NAME = utc.TABLE_NAME
	 and utc.COLUMN_NAME = 'AUDIT_SOURCE'
	 and ut.OBJECT_NAME = uic.TABLE_NAME
	 and ut.OBJECT_NAME not like '%_OLD'
	 and uic.INDEX_NAME =  uic.INDEX_NAME;

---

-- Oracle index NULLs indexed. NULL can be indexed by adding another not nullable column to the index:
CREATE INDEX ix_with_nulls ON table_name (nullable_column, '1');

---

-- Adapted: 04-Jun-2021 (Bob Heckel--https://connor-mcdonald.com/2021/05/26/why-indexes-are-so-fast-at-finding-a-key/)
drop table t;

create table t ( x int );

create unique index ix on t ( x );

declare
  lev number;
begin
  for i in 0 .. 30
  loop
    execute immediate 'truncate table t';
    execute immediate 'drop index ix';
    insert /*+ APPEND */ into t
    select rownum
    from ( select 1 from dual connect by level <= 100 ),
         ( select 1 from dual connect by level <= 100 ),
         ( select 1 from dual connect by level <= 100 )
    where rownum < power(2,i);
    execute immediate 'create unique index ix on t ( x ) ';

    select blevel into lev from user_indexes
    where index_name = 'IX';
    dbms_output.put_line(power(2,i)||' '||lev);
    exit when lev=3;
  end loop;
end;

---

--https://stackoverflow.com/questions/6702367/oracle-function-based-index-selective-uniqueness
create table table1 (
  id number,
  name varchar2(10),
  type varchar2(10),
  is_deleted varchar2(1)
);

CREATE UNIQUE INDEX fn_unique_idx
    ON table1 (CASE WHEN is_deleted='N' THEN id ELSE null END,
               CASE WHEN is_deleted='N' THEN name ELSE null END,
               CASE WHEN is_deleted='N' THEN type ELSE null END);

insert into table1 values( 1, 'Foo', 'Bar', 'N' );
insert into table1 values( 1, 'Foo', 'Bar', 'Y' );
insert into table1 values( 1, 'Foo', 'Bar', 'Y' );
insert into table1 values( 1, 'Foo', 'Bar', 'N' );--ORA-00001: unique constraint (ADMIN.FN_UNIQUE_IDX) violated
insert into table1 values( 1, 'Foo', 'Zee', 'N' );

SELECT COUNT(1) FROM table1;--4

truncate table table1;

drop index fn_unique_idx;

CREATE UNIQUE INDEX fn_unique_idx ON table1 (CASE WHEN is_deleted='N' then (id||','|| name||','|| type) end);

---

-- Columns used by an index, one row per ix each CSV list of columns
with v as(
  SELECT i.table_owner, i.table_name, i.index_name, i.uniqueness, c.column_name, c.column_position
  FROM      all_indexes i
  LEFT JOIN all_ind_columns c
   ON   i.index_name      = c.index_name
   AND  i.owner           = c.index_owner
  WHERE i.table_name  ='MKC_REVENUE_FULL'
  ORDER BY i.table_owner, i.table_name, i.index_name, c.column_position
)
select INDEX_NAME, listagg(COLUMN_NAME, ', ') within group (order by column_position) indexed_col_list
from v
--where index_name='UAT_HC_F_CIX'
group by index_name
order by 1;
