-- Modified: 16-Jan-2020 (Bob Heckel)
-- see also explain_plan.sql

-- The database automatically creates an index for the primary key. That means there is an index on the EMPLOYEE_ID column, 
-- even though there is no CREATE INDEX statement like this one:
CREATE UNIQUE INDEX employees_pk ON employees (employee_id);

CREATE TABLE employees (
   employee_id   NUMBER         NOT NULL,
   first_name    VARCHAR2(1000) NOT NULL,
   last_name     VARCHAR2(1000) NOT NULL,
   date_of_birth DATE           NOT NULL,
   phone_number  VARCHAR2(1000) NOT NULL,
   CONSTRAINT employees_pk PRIMARY KEY (employee_id)
);

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
SELECT
 i.table_owner,
 i.table_name,
 i.index_name,
 i.uniqueness,
 c.column_name,
 f.column_expression
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
WHERE --i.table_owner LIKE UPPER('%someuserpattern%')
 --AND  i.table_name  LIKE UPPER('%sometablepattern%')
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
