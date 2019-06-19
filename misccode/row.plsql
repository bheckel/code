-- Adapted: Tue, Jun 18, 2019 11:32:58 AM (Bob Heckel--https://oracle-base.com/articles/9i/bulk-binds-and-record-processing-9i)

-- See also bulk_collect_forall.plsql

CREATE TABLE forall_test (
  id           NUMBER(10),
  code         VARCHAR2(50),
  description  VARCHAR2(50)
);

ALTER TABLE forall_test ADD (CONSTRAINT forall_test_pk PRIMARY KEY (id));
ALTER TABLE forall_test ADD (CONSTRAINT forall_test_uk UNIQUE (code));

DECLARE
  TYPE t_id_tab          IS TABLE OF forall_test.id%TYPE;
  TYPE t_forall_test_tab IS TABLE OF forall_test%ROWTYPE;

  l_id_tab  t_id_tab          := t_id_tab();
  l_tab     t_forall_test_tab := t_forall_test_tab();
  l_start   NUMBER;  -- for benchmarking
  l_size    NUMBER            := 5;
  l_errcnt  NUMBER;

	ex_dml_errors EXCEPTION;
  PRAGMA EXCEPTION_INIT(ex_dml_errors, -24381);  -- ORA-24381: error(s) in array DML

BEGIN
  EXECUTE IMMEDIATE 'TRUNCATE TABLE forall_test';

  -- Populate collection in a loop
  FOR i IN 1 .. l_size LOOP
    l_id_tab.EXTEND;
    l_id_tab(l_id_tab.LAST)       := i;

    l_tab.EXTEND;
    l_tab(l_tab.LAST).id          := i;
    l_tab(l_tab.LAST).code        := TO_CHAR(SYSTIMESTAMP);
    l_tab(l_tab.LAST).description := 'Description: ' || TO_CHAR(i);
  END LOOP;

  FOR i IN l_tab.FIRST .. l_tab.LAST LOOP
    INSERT /*+ APPEND_VALUES */  INTO forall_test (id, code, description)
    VALUES (l_tab(i).id, l_tab(i).code, l_tab(i).description);
  END LOOP;

  l_start := DBMS_UTILITY.get_time;

  EXECUTE IMMEDIATE 'DELETE FROM forall_test WHERE id=1';

  l_tab(3).id   := 9;
  l_tab(3).code := to_char(SYSTIMESTAMP);  -- will sort to top

	l_tab(4).id := 2;  /* force "ORA-00001: unique constraint (BOBHECKEL.FORALL_TEST_PK) violated" */

  FORALL i IN l_tab.FIRST .. l_tab.LAST SAVE EXCEPTIONS  -- avoid complete rollback if any errors
    UPDATE forall_test
       SET ROW = l_tab(i)  -- magic, update entire row to collection's values
     WHERE id = l_id_tab(i);

  -- Reporting purposes only (and only if 0 errors)
  FOR i IN l_tab.FIRST .. l_tab.LAST LOOP
    DBMS_OUTPUT.put_line(l_tab(i).id || ': rows affected ' || SQL%BULK_ROWCOUNT(i));
  END LOOP;

  COMMIT;  

  DBMS_OUTPUT.put_line('Bulk Updates benchmark: ' || (DBMS_UTILITY.get_time - l_start));

EXCEPTION
   WHEN ex_dml_errors THEN
     l_errcnt := SQL%BULK_EXCEPTIONS.COUNT;
     DBMS_OUTPUT.put_line('Number of failures: ' || l_errcnt);

     FOR i IN 1 .. l_errcnt LOOP
       DBMS_OUTPUT.put_line('Error: ' || i || 
          ' Array Index: ' || SQL%BULK_EXCEPTIONS(i).error_index ||
          ' Message: ' || SQLERRM(-SQL%BULK_EXCEPTIONS(i).ERROR_CODE));
     END LOOP;
END;

select * from forall_test order by 2 DESC -- 3 recs updated successfully thanks to SAVE EXCEPTIONS
