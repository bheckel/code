-- Adapted: 14-Jan-2020 (Bob Heckel -- Oracle DevGym)
-- Modified: 20-Feb-2020 (Bob Heckel)

CREATE OR REPLACE PROCEDURE handle_illness(sneezes_per_hour_in IN PLS_INTEGER)
IS
BEGIN
   IF NOT (sneezes_per_hour_in < 50)
   THEN
      call_doctor();
   ELSE
      sorry_you_are_not_that_sick();
   END IF;
END;
/

BEGIN
   handle_illness(NULL);
END;
/ 

-- When the SNEEZES_PER_HOUR_IN argument is NULL, the expression

-- sneezes_per_hour_in < 50

-- also evaulates to NULL because NULLs propagage. Furthermore, NOT (NULL) evalutes to NULL. NULL is
-- neither TRUE nor FALSE, it is a placeholder for missing data. So the ELSE clause of the IF statement is executed and
-- the SORRY_YOU_ARE_NOT_THAT_SICK procedure is called.

-- Generally, when any part of an expression evaluates to NULL, the entire
-- expression will evaluate to NULL unless wrapped in a function, such as NVL,
-- that converts NULL to a non-NULL value.

---

-- Oracle treats an empty string as NULL:
SELECT     '0 IS NULL???' AS "what is NULL?" FROM dual
    WHERE      0 IS NULL
UNION ALL
   SELECT    '0 is not null' FROM dual
    WHERE     0 IS NOT NULL
UNION ALL
   SELECT ''''' IS NULL???'  FROM dual
    WHERE    '' IS NULL
UNION ALL
   SELECT ''''' is not null' FROM dual 
    WHERE    '' IS NOT NULL;
/*
what is NULL? 
--------------
0 is not null
'' IS NULL???
*/

-- Concatenating the DUMMY column (always containing 'X') with NULL *should* return NULL but doesn't:
SELECT dummy
     , dummy || ''
     , dummy || NULL
  FROM dual
/*
D D D
- - -
X X X
*/

---

-- It is impossible to store an empty string in a VARCHAR2 field. If you try, Oracle just stores a NULL.

-- Oracle does not include rows in an index if all indexed columns are NULL. That means that every index is a 
-- "partial index":

CREATE INDEX idx ON tbl (A, B, C, ...)
	WHERE A IS NOT NULL
	   OR B IS NOT NULL
		 OR C IS NOT NULL
		...

---

-- Oracle does not include rows in an index if all indexed columns are NULL. But this will work to index
-- date_of_birth NULLs because subsidiary_id has a not null constraint:
CREATE INDEX demo_null ON employees (subsidiary_id, date_of_birth);
-- But maybe better to just use this FBI to index nulls:
CREATE INDEX emp_dob ON employees (date_of_birth, '1');

