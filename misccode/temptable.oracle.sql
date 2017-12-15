-- Data will be preserved until the session ends, table is emptied then.  Use
-- DROP TABLE tmpbobh1;
-- to get rid of empty table permanently (after re-logging in)

CREATE GLOBAL TEMPORARY TABLE tmpbobh1 (
  foo1  NUMBER,
  foo2  NUMBER
) ON COMMIT PRESERVE ROWS;  -- session specific
--) ON COMMIT DELETE ROWS;  -- transaction specific

INSERT INTO tmpbobh1 (foo1,foo2) VALUES (66,99);
INSERT INTO tmpbobh1 (foo1,foo2) VALUES (67,100);
INSERT INTO tmpbobh1 (foo1,foo2) VALUES (68,101);


CREATE GLOBAL TEMPORARY TABLE tmpbobh2 (
  foo1  NUMBER,
  foo2  NUMBER
) ON COMMIT PRESERVE ROWS;

INSERT INTO tmpbobh2 (foo1,foo2) VALUES (67,200);
INSERT INTO tmpbobh2 (foo1,foo2) VALUES (68,201);
INSERT INTO tmpbobh2 (foo1,foo2) VALUES (1,2);


select *
from tmpbobh1 a, tmpbobh2 b
where a.foo1=b.foo1
;

-- Left join via Oracle 8i's crippled SQL implementation.  The '(+)' is
-- unintuitively on the opposite table.
select a.foo1, a.foo2
from tmpbobh1 a, tmpbobh2 b
where a.foo1=b.foo1(+) 
;



--CREATE GLOBAL TEMPORARY TABLE bobhlm (
--  MATL_NBR VARCHAR2(18),
--  BATCH_NBR VARCHAR2(10),
--  MATL_DESC VARCHAR2(50),
--  MATL_MFG_DT DATE,
--  MATL_EXP_DT DATE,
--  MATL_TYP VARCHAR2(4)
--) ON COMMIT PRESERVE ROWS;
insert into bobhlm select * from links_material where rownum<11;

