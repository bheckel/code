
-- Created: 25-Jan-2021 (Bob Heckel)

select salesgroup_id, updatedby, ORA_HASH(CONCAT(salesgroup_id, updatedby)) checksum from salesgroup;

---

-- admin@rshdb1

-- ORA_HASH as a checksum comparison

drop table bob;
create table bob as select * from sales_history;
update bob set product='HOHO' where id=2;

with v as (
  select id, product, ORA_HASH(CONCAT(id, product)) checksum from sales_history
), v2 as (
  select id, product, ORA_HASH(CONCAT(id, product)) checksum from bob
)
select v.*
  from v, v2
 where v.id = v2.id
   and v.checksum != v2.checksum;

---

-- admin@rshdb1

-- ORA_HASH as a bucket on which to aggregate

select id, product, units_sold, ORA_HASH(CONCAT(id, product), 4) bucket_0to4 FROM sales_history;

SELECT SUM(units_sold)
  FROM sales_history
  WHERE ORA_HASH(CONCAT(id, product), 4) = 0;
