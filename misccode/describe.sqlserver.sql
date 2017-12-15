
--To list tables type:
sp_help
--OR
select * from SYSOBJECTS where TYPE = 'U' order by NAME

--To List all the databases on the server:
sp_databases

--To list fields in a table called foo:
sp_help tablename
sp_help foo



-- Similar to DESCRIBE in other databases
USE sandbox
EXEC sp_help lu_prescriber


-- Or just this for field names
select top 0 *
from goodclm
