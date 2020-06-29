-- If used among many other expressions in the item list of a SELECT statement,
-- the SELECT must have a GROUP BY clause. No GROUP BY clause is required if 
-- the aggregate function is the only value retrieved by the SELECT statement.


-- Don't use SELECT DISTINCT with a GROUP BY
-- Actually, using GROUP BY without an aggregate function is probably less
-- useful than simply using SELECT DISTINCT instead.

-- Want to total the values contained with a column in a table.
SELECT order_date, sum(net), sum(vat), sum(total)
FROM sales
GROUP BY order_date;


-- or

SELECT state, COUNT(*)
FROM authors
GROUP BY state
HAVING COUNT(*) > 1
