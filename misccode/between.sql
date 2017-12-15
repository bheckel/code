-- SQL Server
USE pubs
GO
SELECT SUM(qty)
FROM sales
WHERE ord_date BETWEEN '01/01/1993' AND '12/31/1993'
