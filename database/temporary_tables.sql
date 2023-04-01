
CREATE GLOBAL TEMPORARY TABLE temp_sales_by_month (
    month VARCHAR2(7),
    product_id NUMBER,
    total_sales NUMBER
) ON COMMIT PRESERVE ROWS;

---

CREATE GLOBAL TEMPORARY TABLE t2
ON COMMIT PRESERVE ROWS
AS 
SELECT amtpd
FROM t;

truncate table t2;  --mandatory or won't be able to drop
drop table t2;
