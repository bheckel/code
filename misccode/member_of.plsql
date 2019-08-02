
-- Adapted: 30-Jul-19 (Bob Heckel -- http://oracle-developer.net/display.php?id=301) 
-- see also pass_collection_to_procedure.plsql

CREATE OR REPLACE TYPE number_ntt AS TABLE OF NUMBER;

DECLARE
  in_list  number_ntt := number_ntt();
  v_cnt    PLS_INTEGER;
  v_hits   PLS_INTEGER := 0;

BEGIN
  /* Add 100 elements to the collection */
  in_list.EXTEND(100);

  /* Populate the collection */
  FOR i IN 1 .. 100 LOOP
    in_list(i) := i;
  END LOOP;

  /* TABLE operator... */
  FOR i IN 1 .. 10000 LOOP
    SELECT COUNT(*) INTO v_cnt FROM TABLE(in_list) WHERE column_value = i;
    IF v_cnt > 0 THEN
       v_hits := v_hits + 1;
    END IF;
  END LOOP;
  v_hits := 0;

  /* MEMBER condition... */
  FOR i IN 1 .. 10000 LOOP
    IF i MEMBER OF in_list THEN
       v_hits := v_hits + 1;
    END IF;
  END LOOP;
  v_hits := 0;

  /* Collection loop... */
  FOR i IN 1 .. 10000 LOOP
    FOR ii IN 1 .. in_list.COUNT LOOP
       IF i = in_list(ii) THEN
          v_hits := v_hits + 1;
          EXIT;
       END IF;
    END LOOP;
  END LOOP;
END;
/
/*
[TABLEOP (v_hits=100)] 1.22 seconds
[MEMBER  (v_hits=100)] 0.04 seconds
[LOOP    (v_hits=100)] 0.21 seconds
*/
