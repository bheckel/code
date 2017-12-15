-- SQL Server

USE pubs
SELECT ord_num + ' z ' + cast(qty as varchar(20))
FROM sales
WHERE qty > 10


-- Oracle (single/double quotes important)
select patron_id || ' and ' || insert_dt as "Bar" from activity_log
