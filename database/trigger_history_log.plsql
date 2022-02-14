
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

---

CREATE OR REPLACE TRIGGER SETARS.MKC_REVENUE_SOURCE_TORIND_IUD BEFORE INSERT OR UPDATE OR DELETE ON MKC_REVENUE_SOURCE_TORIND FOR EACH ROW 
  /* CreatedBy: Bob Heckel
  **   Created: 26-Jan-22
  **   Purpose: History trigger for MKC_REVENUE_SOURCE_TORIND
  **  Modified: 26-Jan-22-(boheck) Initial version - RION-46391
  */
  declare 
    constantSystimestamp TIMESTAMP(6) := systimestamp;
  begin 
    ------------------------ inserting -----------------------
    if (INSERTING) Then
      if (:new.ACTUAL_UPDATED is null) Then
        :new.ACTUAL_UPDATED := constantSystimestamp;
      end if;

      if (:new.ACTUAL_UPDATEDBY is null) Then
        :new.ACTUAL_UPDATEDBY := nvl(sys_context('setars_context',
                                                 'actual_employee_id'),
                                     nvl(sys_context('setars_context',
                                                     'employee_id'),0));
      end if;
      
      if (:new.AUDIT_SOURCE is null) then
        :new.AUDIT_SOURCE := nvl(sys_context('USERENV', 'HOST'), 'Unknown');
      end if;

      if (:new.created is null) then
        :new.created := sysdate;
      end if;

      if (:new.updated is null) then
        :new.updated := sysdate;
      end if;

      if (:new.updatedby is null) then
        :new.updatedby := nvl(sys_context('setars_context', 'employee_id'),
                              0);
      end if;
    end if;  -- INSERTING
    ------------------------ inserting -----------------------

    ------------------------ updating -----------------------
    if (UPDATING) Then 
      if ((:old.ACTUAL_UPDATED is null) or
         (nvl(:new.ACTUAL_UPDATED, :old.ACTUAL_UPDATED) =
         :old.ACTUAL_UPDATED)) Then
        :new.ACTUAL_UPDATED := constantSystimestamp;
      end if;

      if ((:old.ACTUAL_UPDATEDBY is null) or
         (nvl(:new.ACTUAL_UPDATEDBY, :old.ACTUAL_UPDATEDBY) =
         :old.ACTUAL_UPDATEDBY)) Then
        :new.ACTUAL_UPDATEDBY := nvl(sys_context('setars_context',
                                                 'actual_employee_id'),
                                     nvl(sys_context('setars_context',
                                                 'employee_id'),0));
      end if;

      if (NOT UPDATING('AUDIT_SOURCE')) then
        :new.AUDIT_SOURCE := nvl(sys_context('USERENV', 'HOST'), 'Unknown');
      end if;
     
      if NOT UPDATING('H_VERSION') Then
        :new.H_VERSION := nvl(:old.H_VERSION, 0) + 1;
      end if;

      if NOT UPDATING('UPDATED') then
        :new.updated := sysdate;
      end if;

      if NOT UPDATING('UPDATEDBY') then
        :new.updatedby := nvl(sys_context('setars_context', 'employee_id'),
                              0);
      end if;

      INSERT /*+ append */ INTO MKC_REVENUE_SOURCE_TORIND_HIST (
        -- EDIT!!! 1 of 6
        MKC_REVENUE_SOURCE_TORIND_ID,
        SDM_BUSINESS_KEY,
        REPORT_DATE,
        TOR_IND,
        SOURCE_DB,
        LAST_UPDATED,
        CREATED,
        CREATEDBY,
        UPDATED,
        UPDATEDBY,
        ACTUAL_UPDATED,
        ACTUAL_UPDATEDBY,
        AUDIT_SOURCE,
        H_VERSION,
        RETIRED_TIME,
        WM_OPTYPE  -- only exists in _HIST tbl
      )
      VALUES (
        -- EDIT!!! 2 of 6
        :old.MKC_REVENUE_SOURCE_TORIND_ID,
        :old.SDM_BUSINESS_KEY,
        :old.REPORT_DATE,
        :old.TOR_IND,
        :old.SOURCE_DB,
        :old.LAST_UPDATED,
        :old.CREATED,
        :old.CREATEDBY,
        :old.UPDATED,
        :old.UPDATEDBY,
        :old.ACTUAL_UPDATED,
        :old.ACTUAL_UPDATEDBY,
        :old.AUDIT_SOURCE,
        :old.H_VERSION,
        (constantSystimestamp - INTERVAL '0.001' SECOND),  --RETIRED_TIME
        decode(:old.H_VERSION, 0, 'I', 'U')  -- WM_OPTYPE
      );
    end if;  -- UPDATING
    ------------------------ updating -----------------------

    ------------------------ deleting -----------------------
    if (DELETING) then     
      -- First add record from before delete
      INSERT /*+ append */ INTO MKC_REVENUE_SOURCE_TORIND_HIST (
        -- EDIT!!! 3 of 6
        MKC_REVENUE_SOURCE_TORIND_ID,
        SDM_BUSINESS_KEY,
        REPORT_DATE,
        TOR_IND,
        SOURCE_DB,
        LAST_UPDATED,
        CREATED,
        CREATEDBY,
        UPDATED,
        UPDATEDBY,
        ACTUAL_UPDATED,
        ACTUAL_UPDATEDBY,
        AUDIT_SOURCE,
        H_VERSION,
        RETIRED_TIME,
        WM_OPTYPE  -- only exists in _HIST tbl
      )
      VALUES (
        -- EDIT!!! 4 of 6
        :old.MKC_REVENUE_SOURCE_TORIND_ID,
        :old.SDM_BUSINESS_KEY,
        :old.REPORT_DATE,
        :old.TOR_IND,
        :old.SOURCE_DB,
        :old.LAST_UPDATED,
        :old.CREATED,
        :old.CREATEDBY,
        :old.UPDATED,
        :old.UPDATEDBY,
        :old.ACTUAL_UPDATED,
        :old.ACTUAL_UPDATEDBY,
        :old.AUDIT_SOURCE,
        :old.H_VERSION,
        (constantSystimestamp - INTERVAL '0.001' SECOND),  --RETIRED_TIME
        decode(:old.H_VERSION, 0, 'I', 'U')  -- WM_OPTYPE
      );

      -- Then add the record deleted
      INSERT /*+ append */ INTO MKC_REVENUE_SOURCE_TORIND_HIST (
        -- EDIT!!! 5 of 6
        MKC_REVENUE_SOURCE_TORIND_ID,
        SDM_BUSINESS_KEY,
        REPORT_DATE,
        TOR_IND,
        SOURCE_DB,
        LAST_UPDATED,
        CREATED,
        CREATEDBY,
        UPDATED,
        UPDATEDBY,
        ACTUAL_UPDATED,
        ACTUAL_UPDATEDBY,
        AUDIT_SOURCE,
        H_VERSION,
        RETIRED_TIME,
        WM_OPTYPE  -- only exists in _HIST tbl
      )
      VALUES (
        -- EDIT!!! 6 of 6
        :old.MKC_REVENUE_SOURCE_TORIND_ID,
        :old.SDM_BUSINESS_KEY,
        :old.REPORT_DATE,
        :old.TOR_IND,
        :old.SOURCE_DB,
        :old.LAST_UPDATED,
        :old.CREATED,
        :old.CREATEDBY,
        SYSDATE, --UPDATED
        nvl(sys_context('setars_context', 'employee_id'), 0),  --UPDATEDBY
        constantSystimestamp,  --.ACTUAL_UPDATED
        nvl(sys_context('setars_context', 'actual_employee_id'), nvl(sys_context('setars_context', 'employee_id'), 0)),  --ACTUAL_UPDATEDBY
        nvl(sys_context('USERENV', 'HOST'), 'Unknown'),  --:AUDIT_SOURCE
        :old.H_VERSION,
        (constantSystimestamp - INTERVAL '0.001' SECOND),  --:RETIRED_TIME
        'D'
      );
    end if;  -- DELETING
    ------------------------ deleting -----------------------
end;
/
ALTER TRIGGER STARS.MKC_REVENUE_SOURCE_TORIND_IUD ENABLE;

