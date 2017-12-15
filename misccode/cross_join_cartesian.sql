$ sqlite3 Essence.db

-- If the input tables have x and y columns, respectively, the resulting table
-- will have x+y columns. If the input tables have n and m rows, respectively,
-- the resulting table will have n·m rows.

sqlite> select count(*) from student CROSS JOIN teach;

-- same

sqlite> select count(*) from student, teach;

-- Useful to find things like:
-- E4 Who takes both CS112 and CS114? (CROSS JOIN self join). Both-And. Type 1.
select a.Sno
from Take as a, Take as b
where a.Sno=b.Sno
  and (a.Cno="CS112") and (b.Cno="CS114")
;

