-- F5 in Toad to execute
-- or
-- $ sqlplus pks/dev123dba@usdev388 @hello2.plsql

set echo on;

drop table temp;

create table temp
	(col1  number(9,4),
	 col2  number(4),
 	 text  char(55));
/

--'anonymous' block
DECLARE
  -- Not case-sensitive
  x  NUMBER := 100;
  y  CONSTANT REAL := 500.25;
  z  INTEGER DEFAULT 42;
  zz INTEGER(4) NOT NULL := 4242;  -- 'NOT NULL's must be initialized
  --i, j, k SMALLINT;  -- not allowed, must do 1 per line
  c  INTEGER;   -- if later say c=c+1, c is NULL b/c c is NULL here, must init
BEGIN
  FOR i IN 1..10 LOOP
    IF MOD(i,2) = 0 THEN     -- i is even
      INSERT INTO temp VALUES (i, x, 'i (even)');
    ELSE
      INSERT INTO temp VALUES (i, x, 'i (odd)');
    END IF;
    x := x + 100;        
  END LOOP;
  COMMIT;
END;
/

SELECT * 
FROM temp
;
