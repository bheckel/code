-- Adapted: 14-Jan-2020 (Bob Heckel -- Oracle DevGym)

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
-- neither TRUE nor FALSE. So the ELSE clause of the IF statement is executed and
-- the SORRY_YOU_ARE_NOT_THAT_SICK procedure is called.

-- Generally, when any part of an expression evaluates to NULL, the entire
-- expression will evaluate to NULL unless wrapped in a function, such as NVL,
-- that converts NULL to a non-NULL value.
