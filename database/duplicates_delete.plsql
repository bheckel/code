------------------------------------
-- Created: 10-Feb-2021 (Bob Heckel) 
------------------------------------

DECLARE
  TYPE idTable IS TABLE OF VARCHAR2(2000);
  id_table idTable;

  CURSOR c1 IS
    select sdm_business_key
    from mkc_revenue_base
where rownum<2150000
    having count(*)>1
    group by sdm_business_key;

BEGIN
  OPEN c1;
  LOOP
    FETCH c1 BULK COLLECT
      INTO id_table LIMIT 1000;
  
    EXIT WHEN id_table.COUNT = 0;
  
    FORALL i IN 1 .. id_table.COUNT
      DELETE FROM mkc_revenue_base
         WHERE sdm_business_key = id_table(i)
           AND source_db != 'SDM_REVENUE';
           
    dbms_output.put_line(sql%rowcount || ' ' || id_table(1));
    --COMMIT;
    rollback;
  END LOOP;
  --COMMIT;
  rollback;

  CLOSE c1;
END;
