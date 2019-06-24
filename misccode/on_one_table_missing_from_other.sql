-- See also csv_list_to_table.sql

---

-- On a but not on b
with a as(
	select 9802600 id from dual
	union all select 9032760 id from dual
	union all select 99 id from dual
	union all select 9000800 id from dual
),
b AS(
select activity_id from ACTIVITY 
)
SELECT a.*, b.* FROM a, b WHERE a.id=b.activity_id(+) AND b.activity_id IS NULL

---

WITH a AS (
  SELECT trim(COLUMN_VALUE) ids
  FROM ( SELECT '9999999, 5, 100' ids FROM dual ), xmltable(('"' || REPLACE(ids, ',', '","') || '"'))
),
b AS(
SELECT activity_id
  FROM ACTIVITY
)
SELECT a.*, b.* FROM a, b WHERE a.ids=b.activity_id(+) AND b.activity_id IS NULL

---

CREATE TABLE zorion32822_missing as
select orion_contact_id from zorion32822@eds
MINUS
select contact_id from contact_base c 
where c.contact_id in (select orion_contact_id from zorion32822@eds);

-- same

SELECT a.*
FROM zorion32822 a LEFT JOIN contact_base b ON a.orion_contact_id=b.contact_id
WHERE b.contact_id IS NULL
