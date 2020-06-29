-- Find records on bigtbl that are not on littletbl.
SELECT bigtbl.*
FROM bigtbl LEFT JOIN littletbl ON bigtbl.the_field=littletbl.the_field
WHERE littletbl.the_field Is Null;


-- Find records on littletbl that are not on bigtbl.
SELECT littletbl.*
FROM littletbl LEFT JOIN bigtbl ON bigtbl.the_field=littletbl.the_field
WHERE bigtbl.the_field Is Null;

