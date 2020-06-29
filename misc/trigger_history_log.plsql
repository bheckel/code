
/* https://docs.oracle.com/database/121/LNPLS/static.htm#LNPLS622 */
DROP TABLE emp;
CREATE TABLE emp AS SELECT * FROM employees;
 
DROP TABLE log;
CREATE TABLE log (
  log_id   NUMBER(6),
  up_date  DATE,
  new_sal  NUMBER(8,2),
  old_sal  NUMBER(8,2)
);
 
-- Autonomous trigger on emp table:
CREATE OR REPLACE TRIGGER log_sal
  BEFORE UPDATE OF salary ON emp FOR EACH ROW
DECLARE
  -- An autonomous routine never reads or writes database state (i.e. it neither queries nor updates any table)
  PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN
  INSERT INTO log (
    log_id,
    up_date,
    new_sal,
    old_sal
  )
  VALUES (
    :OLD.employee_id,
    SYSDATE,
    :NEW.salary,
    :OLD.salary
  );
  COMMIT;
END;
/
UPDATE emp
SET salary = salary * 1.05
WHERE employee_id = 115;
 
COMMIT;
 
UPDATE emp
SET salary = salary * 1.05
WHERE employee_id = 116;
 
ROLLBACK;
 
-- Show that both committed and rolled-back updates add rows to log table
SELECT * FROM log WHERE log_id = 115 OR log_id = 116;
