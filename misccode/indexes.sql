-- see also explain_plan.sql

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
