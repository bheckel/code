-- Modified: 10-Mar-2022 (Bob Heckel)
-- See also csv_list_to_table.sql

---

with a as (
	select 9802600 id from dual
	union all select 9032760 id from dual
	union all select 99 id from dual
  union all select 888 id from dual--1.
),
b as (
	select 9802600 id from dual
	union all select 9032760 id from dual
	union all select 99 id from dual
	union all select 9000800 id from dual--2.
)
-- On a but not on b
--SELECT a.* FROM a, b WHERE a.id=b.id(+) AND b.id IS NULL;--1.
-- On b but not on a
SELECT b.* FROM a, b WHERE a.id(+)=b.id AND a.id IS NULL;--2.

-- same:

with a as(
	select 9802600 id from dual
	union all select 9032760 id from dual
	union all select 99 id from dual
  union all select 888 id from dual--1.
),
b AS(
	select 9802600 id from dual
	union all select 9032760 id from dual
	union all select 99 id from dual
	union all select 9000800 id from dual--2.
)
-- On a but not on b
--select * from a
--MINUS
--select * from b;--1.
-- On b but not on a
select * from b
MINUS
select * from a;--2.
