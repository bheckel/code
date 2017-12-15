
-- List information about each owner's table in a database (SQL Server at least).
select *
from information_schema.tables
where table_type='BASE TABLE' and table_schema='rheckel'
