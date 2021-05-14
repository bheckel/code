
-- Insert records in another table where the cursor key matches

DECLARE
  TYPE idTable IS TABLE OF NUMBER;
  id_table idTable;

  CURSOR rowCursor IS
    SELECT mkc_revenue_id
      FROM mkc_revenue_full
     WHERE sdm_business_key in('00','00000506');
BEGIN
  OPEN rowCursor;

  LOOP
    FETCH rowCursor BULK COLLECT
      INTO id_table LIMIT 1000;
  
    EXIT WHEN id_table.COUNT = 0;
    
    for i in 1 .. id_table.count loop
      dbms_output.put_line(i || ' ' || id_table(i));
    end loop;
  
    FORALL i IN 1 .. id_table.COUNT
      INSERT INTO mkc_revenue_full_13may (mkc_revenue_id, hash_column_sr)
                                   SELECT mkc_revenue_id, hash_column_sr
                                     FROM mkc_revenue_full
                                    WHERE mkc_revenue_id = id_table(i);
  
    --COMMIT;
    rollback;
  END LOOP;

  --COMMIT;
  rollback;

  CLOSE rowCursor;
END;
