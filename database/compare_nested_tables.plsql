
-- Adapted: 04-Nov-2020 (Bob Heckel -- https://github.com/oracle/oracle-db-examples/blob/master/plsql/collections/nested-table-equality-check.sql)

DECLARE
   TYPE number_tbl IS TABLE OF INTEGER;

   tab_1 number_tbl := number_tbl(1, 2, 3, 4, 5, 6, 7);
   tab_2 number_tbl := number_tbl(7, 6, 5, 4, 3, 2, 1);
   tab_3 number_tbl := number_tbl();
   tab_4 number_tbl := number_tbl();
   tab_5 number_tbl := number_tbl(null);
   tab_6 number_tbl := number_tbl(null);

   PROCEDURE check_for_equality(in_tab_a   IN number_tbl,
                                in_tab_b   IN number_tbl) IS
     v_equal   BOOLEAN := in_tab_a = in_tab_b;
   BEGIN
     -- "Print" a boolean
     DBMS_OUTPUT.put_line(
       'Equal? ' || CASE
                      WHEN v_equal IS NULL THEN 'null'
                      WHEN v_equal THEN 'equal'
                      ELSE 'not equal'
                    END
     );
   END check_for_equality;
BEGIN
  -- Order of elements is not significant 
  check_for_equality(tab_1, tab_2); --equal
  tab_1.EXTEND(1);

  -- If the collections have different numbers of elements, "=" returns FALSE;
  check_for_equality(tab_1, tab_2); --now not equal
  tab_2.EXTEND(1);

  -- If they have the same number of elements, but at least one of the values in 
  -- either collection is NULL, "=" returns NULL
  check_for_equality(tab_1, tab_2); --now null

  check_for_equality(tab_1, tab_3); --not equal

  -- Two initialized, but empty collections are equal
  check_for_equality(tab_3, tab_4); --equal

  check_for_equality(tab_5, tab_6); --null
END;
/
