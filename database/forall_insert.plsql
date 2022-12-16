--  Created: 11-Jun-2021 (Bob Heckel)
-- Modified: 13-Dec-2022 (Bob Heckel)

-- The FORALL basically means "perform the following DML on this collection" and it expects a single SQL statement 
-- with DML that will be executed server-side once for each record in the collection.  You can use IF/THEN/ELSE/ 
-- before or after your FORALL statement, but not in the middle of it.  You can manipulate your cursor query or 
-- manipulate the collection until you are ready to use the FORALL to perform one single dml statement affecting 
-- all rows in the collection. Or, if you cannot get this to work, you can always use a normal loop with conventional
-- (not bulk) dml operations.

---

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
  
    -- see forall_update_set_row.plsql for SAVE EXCEPTIONS
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

---

-- Bulk collect large insert see also insert_into.sql

declare
  ex_dml_errors EXCEPTION;
  PRAGMA EXCEPTION_INIT(ex_dml_errors, -24381);  -- ORA-24381: error(s) in array DML
  l_errcnt  NUMBER;

  CURSOR c1 IS 
    SELECT 
-- Partial inserts based on a predicate:
--UID_MKC_INVOICE.NEXTVAL mkc_revenue_id, 
-- Full inserts, no collision possible:
--KMC_REVENUE_ID,
CREATED,
CREATEDBY,
UPDATED,
UPDATEDBY,
H_VERSION,
ACTUAL_UPDATED,
ACTUAL_UPDATEDBY,
RETIRED_TIME,
AUDIT_SOURCE,
USM_RATE_ATLAS,
CLOUD_PROVIDER_SR
    FROM MKC_REVENUE_FULL_ESR 
    WHERE rownum<9
    ;

    TYPE t_idtbl IS TABLE OF c1%ROWTYPE;
    id_table t_idtbl;
 BEGIN
   OPEN c1; 
   LOOP
     FETCH c1 BULK COLLECT INTO id_table;
     EXIT WHEN id_table.COUNT = 0;
--       FOR i IN 1 .. id_table.COUNT LOOP
--         DBMS_OUTPUT.put_line('x ' || id_table(i).created);
--       end loop;

     FORALL i IN 1 .. id_table.COUNT SAVE EXCEPTIONS
       INSERT  INTO zz_tmp
       (
--MKC_REVENUE_ID,
CREATED,
CREATEDBY,
UPDATED,
UPDATEDBY,
H_VERSION,
ACTUAL_UPDATED,
ACTUAL_UPDATEDBY,
RETIRED_TIME,
AUDIT_SOURCE,
USM_RATE_ATLAS,
CLOUD_PROVIDER_SR
       )
       VALUES
        (
--id_table(i).MKC_REVENUE_ID,
id_table(i).CREATED,
id_table(i).CREATEDBY,
id_table(i).UPDATED,
id_table(i).UPDATEDBY,
id_table(i).H_VERSION,
id_table(i).ACTUAL_UPDATED,
id_table(i).ACTUAL_UPDATEDBY,
id_table(i).RETIRED_TIME,
id_table(i).AUDIT_SOURCE,
id_table(i).USM_RATE_ATLAS,
id_table(i).CLOUD_PROVIDER_SR
        );
    COMMIT;
  END LOOP;      

EXCEPTION
  WHEN ex_dml_errors THEN
    l_errcnt := SQL%BULK_EXCEPTIONS.COUNT;
    DBMS_OUTPUT.put_line('Number of failures: ' || l_errcnt);

    FOR i IN 1 .. l_errcnt LOOP
      DBMS_OUTPUT.put_line('Error: ' || i || 
         ' Array Index: ' || SQL%BULK_EXCEPTIONS(i).error_index ||
         ' Message: ' || SQLERRM(-SQL%BULK_EXCEPTIONS(i).ERROR_CODE));
    END LOOP;

  WHEN OTHERS THEN
    rollback;
    DBMS_OUTPUT.put_line(SQLCODE || ':' || SQLERRM || ': ' || DBMS_UTILITY.format_error_backtrace);
END;

