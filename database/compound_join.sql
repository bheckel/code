
-- .read compound_join_build.sql
-- .h on
-- .read compound_join.sql

SELECT * FROM x;
SELECT * FROM y;
SELECT * FROM z;
SELECT * FROM x JOIN y ON x.a=y.c;
SELECT * FROM x JOIN y ON x.a=y.c  LEFT OUTER JOIN z ON y.c=z.a;
-- same
SELECT * FROM x JOIN y ON x.a=y.c  LEFT OUTER JOIN z ON x.a=z.a;
