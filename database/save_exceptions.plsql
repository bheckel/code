-- Modified: 11-Jun-2021 (Bob Heckel)
declare
  ex_dml_errors EXCEPTION;
  PRAGMA EXCEPTION_INIT(ex_dml_errors, -24381);  -- ORA-24381: error(s) in array DML
  l_errcnt  NUMBER;

  CURSOR c1 IS 
    SELECT 
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

