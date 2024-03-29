-- Modified: 09-Feb-2023 (Bob Heckel)

-- Predefined PL/SQL Exceptions: https://docs.oracle.com/cd/A97630_01/appdev.920/a96624/07_errs.htm

-- The PL/SQL run-time engine will raise exceptions whenever the Oracle
-- database detects a problem or it executes a RAISE or RAISE_APPLICATION_ERROR
-- statement in your code. You can then trap or handle these exceptions in the
-- exception section - or let the exception propagate unhandled to the enclosing
-- block or host environment.
--
-- If you want processing in your block to continue, even if an exception was
-- raised, enclose the code that might raise an exception in its own BEGIN-END
-- nested block. Then add an exception to that block, trap the error, record
-- information about what went wrong, and then allow the (now) outer block to
-- continue.

-- See also suppress_rowlevel_dml_errors.plsql

---

  EXCEPTION
    WHEN OTHERS THEN
      DBMS_OUTPUT.put_line('ERROR: ' || SQLERRM || ':' || DBMS_UTILITY.format_error_backtrace || ' (LOAD_HISTORY)');

---

-- ERROR_CODE is an integer in the range -20999..-20000 and message is a character string of at most 2048 bytes
-- But watch out! Several built-in packages, including DBMS_OUTPUT and DBMS_DESCRIBE, use error numbers 
-- between −20005 and −20000.
BEGIN dbms_output.put_line(SQLERRM(0)); END; -- ORA-0000: normal, successful completion

---

CREATE OR REPLACE PROCEDURE log_error
IS
BEGIN
  DBMS_OUTPUT.put_line('Error Trapped: ' || SQLCODE);
END;

DECLARE
  my_dream   VARCHAR2(2);
  -- Unnecessary because it's already a predefined Oracle error:
  --VALUE_ERROR EXCEPTION;
  --PRAGMA EXCEPTION_INIT(VALUE_ERROR, -6502);
BEGIN
  my_dream := 'JUSTICE';
EXCEPTION 
  WHEN VALUE_ERROR THEN log_error();
  -- Same
  /*WHEN OTHERS THEN log_error();*/

  DBMS_OUTPUT.put_line('logged');

  RAISE;  -- *now* fail and propagate VALUE_ERROR/ORA-06502 unhandled to the enclosing block
  -- In this way we record where the error occurred in the application but still stop the enclosing 
  -- block(s) without losing the error information.
END;
/*
Error Trapped: -6502
logged

Error starting at line : 25 in command -
DECLARE
  my_dream   VARCHAR2(2);
...
END;
Error report -
ORA-06502: PL/SQL: numeric or value error: character string buffer too small
ORA-06512: at line 15
ORA-06512: at line 7
06502. 00000 -  "PL/SQL: numeric or value error%s"
*Cause:    An arithmetic, numeric, string, conversion, or constraint error
           occurred. For example, this error occurs if an attempt is made to
           assign the value NULL to a variable declared NOT NULL, or if an
           attempt is made to assign an integer larger than 99 to a variable
           declared NUMBER(2).
*Action:   Change the data, how it is manipulated, or how it is declared so
           that values do not violate constraints.
*/

---

 EXCEPTION
  WHEN OTHERS THEN
    errMsg := SQLERRM;
    ROLLBACK;
    EXECUTE IMMEDIATE 'insert into ACCOUNT_TRANSFORMATION_LOG                            
                        VALUES(:1, :2, :3)'
      USING rec.account_id, 'Add New Account Error: ' || errMsg, sysdate;
    COMMIT;                        
 END;

---

BEGIN
  -- Print code descriptions:

  -- Outside the exception handler it returns 0:
  -- "ORA-0000: normal, successful completion"
  dbms_output.put_line(SQLERRM);

  -- "ORA-0000: normal, successful completion"
  dbms_output.put_line(SQLERRM(0));

  -- "User-Defined Exception"
  dbms_output.put_line(SQLERRM(1));

  -- "ORA-01855: AM/A.M. or PM/P.M. required"
  dbms_output.put_line(SQLERRM(-1855));

  -- Positive "user" code. Oracle uses only 1 and 100 on the positive side of the integer range. While it is possible that 
  -- Oracle will, over time, use other positive numbers, it is very unlikely.
  -- "-1855: non-ORACLE exception"
  dbms_output.put_line(SQLERRM(1855));

  -- "ORA-20000: 
  dbms_output.put_line(SQLERRM(-20000));

  RAISE TOO_MANY_ROWS;

EXCEPTION
  WHEN OTHERS
    -- ORA-01422: exact fetch returns more than requested number of rows
    dbms_output.put_line(SQLERRM);
    -- Same (except can't use it to lookup errors as you can with SQLERRM), upside is it won't truncate
    -- at 512 bytes like SQLERRM, it goes to 1999
    dbms_output.put_line(DBMS_UTILITY.format_error_stack);
END;

---

DECLARE
  sal_calc NUMBER(8,2);
BEGIN
  INSERT INTO employees_temp (employee_id, salary, commission_pct)
  VALUES (301, 2500, 0);
 
  BEGIN
    SELECT (salary / commission_pct) INTO sal_calc
    FROM employees_temp
    WHERE employee_id = 301;
  EXCEPTION
    WHEN ZERO_DIVIDE THEN
      DBMS_OUTPUT.PUT_LINE('Substituting 2500 for undefined number.');  -- reaches
      sal_calc := 2500;
  END;
 
  INSERT INTO employees_temp VALUES (302, sal_calc/100, .1);
  DBMS_OUTPUT.PUT_LINE('Enclosing block: Row inserted.');  -- reaches
EXCEPTION
  WHEN ZERO_DIVIDE THEN 
    DBMS_OUTPUT.PUT_LINE('Enclosing block: Division by zero.');
    -- Execution continues
END;
/

---

DECLARE 
  l_id   emp.empno%TYPE := 7369; 
  l_name emp.ename%TYPE; 
BEGIN 
  SELECT empno, ename
    INTO l_id, l_name 
    FROM emp 
   WHERE empno = l_id;  

  DBMS_OUTPUT.put_line('Name: '||  l_name); 

  -- This OTHERS ("ORA-01830: date format picture ends before converting entire input string") error
  -- will be masked if NO_DATA_FOUND hits first
  DBMS_OUTPUT.put_line(TO_DATE('2010 10 10 44:55:66', 'YYYSS'));

EXCEPTION 
  -- Can chain but can't use AND
  WHEN NO_DATA_FOUND OR VALUE_ERROR THEN 
    dbms_output.put_line('No such emp!'); 
    -- There is no fall-thru to OTHERS here

  WHEN OTHERS THEN 
    dbms_output.put_line(SQLCODE || ':' || SQLERRM || ': ' || DBMS_UTILITY.format_error_backtrace);
    -- Reraising the exception passes it to the enclosing block, which can handle it further
    RAISE;
END;

---

DECLARE 
   c_id           customers.id%type := &cc_id; 
   c_name         customerS.Name%type; 
   c_addr         customers.address%type;  
   -- user defined exception 
   ex_invalid_id  EXCEPTION; 
BEGIN 
   IF c_id <= 0 THEN 
      RAISE ex_invalid_id;  -- a business rule has been violated, a naked RAISE is a syntax error here
   ELSE 
      SELECT  name, address INTO  c_name, c_addr 
      FROM customers 
      WHERE id = c_id;
      DBMS_OUTPUT.PUT_LINE ('Name: '||  c_name);  
      DBMS_OUTPUT.PUT_LINE ('Address: ' || c_addr); 
   END IF; 

EXCEPTION 
   WHEN ex_invalid_id THEN 
      dbms_output.put_line('ID must be greater than zero!'); 
   WHEN NO_DATA_FOUND THEN 
      dbms_output.put_line('No such customer!'); 
   WHEN OTHERS THEN 
      dbms_output.put_line('Error!');  
END; 

---

-- Things like NO_DATA_FOUND and TOO_MANY_ROWS have this system predefined label by the STANDARD package, others
-- like ORA-01438 "value larger than specified precision..." are un-named system predefined exceptions
DECLARE  
   e_bad_date_format   EXCEPTION;  
   PRAGMA EXCEPTION_INIT(e_bad_date_format, -1830);  
BEGIN  
   DBMS_OUTPUT.put_line(TO_DATE ('2010 10 10 44:55:66', 'YYYSS'));  
EXCEPTION  
   WHEN e_bad_date_format THEN  
     DBMS_OUTPUT.put_line('Bad date format');  
END; 

-- Override an Oracle predefined code
DECLARE
  deadlock_detected EXCEPTION;
  -- ORA-00060 (deadlock detected while waiting for resource) 
  PRAGMA EXCEPTION_INIT(deadlock_detected, -60);
BEGIN
  ...
EXCEPTION
  WHEN deadlock_detected THEN
    ...
END;
/

---

CREATE PROCEDURE account_status (
  due_date DATE,
  today    DATE
) AUTHID DEFINER
IS
BEGIN
  IF due_date < today THEN  -- explicitly raise exception 
    -- First argument must be an integer value between -20999 and -20000.
    -- This (vs. RAISE) associates an error message with the exception.
    RAISE_APPLICATION_ERROR(-20000, 'Account past due.');  -- goes unhandled, assumes user can't see DBMS_OUTPUT buffer
  END IF;
END;
/
 
DECLARE
  past_due EXCEPTION;                        -- declare exception
  PRAGMA EXCEPTION_INIT (past_due, -20000);  -- assign error code to exception
BEGIN
  account_status (TO_DATE('01-JUL-2010', 'DD-MON-YYYY'),
                  TO_DATE('09-JUL-2010', 'DD-MON-YYYY'));   -- invoke procedure

EXCEPTION
  WHEN past_due THEN  -- handle exception, "WHEN OTHERS" also works here
    DBMS_OUTPUT.PUT_LINE(TO_CHAR(SQLERRM(-20000)));
    -- Better, doesn't truncate > 512 char messages
    DBMS_OUTPUT.put_line(DBMS_UTILITY.format_error_stack());
END;
/

---

CREATE OR REPLACE PROCEDURE update_reference_owner IS
  TYPE numberTable IS TABLE OF NUMBER;

  referenceIdTable numberTable;
  referenceEmployeeIdTable numberTable;
  v_new_owner number := 9999 ;

  BEGIN
    EXECUTE IMMEDIATE 'select r.reference_id, re.reference_employee_id
                          from reference r,
                               REFERENCE_EMPLOYEE re,
                               opportunity_employee    oe,
                               list_of_values          l
                         where r.reference_id = re.reference_id
                           and r.opportunity_id = oe.opportunity_id
                           and re.employee_id ^= :1'
                    BULK COLLECT INTO referenceIdTable, referenceEmployeeIdTable
                    USING v_new_owner;  

    FOR i IN 1 .. referenceIdTable.COUNT LOOP
      BEGIN 
       UPDATE reference_employee_base re2
          SET re2.EMPLOYEE_ID = v_new_owner,
              re2.UPDATED     = re2.UPDATED,
              re2.UPDATEDBY   = re2.UPDATEDBY
        WHERE re2.REFERENCE_EMPLOYEE_ID = referenceEmployeeIdTable(i);
           
       EXCEPTION
         /* If there is another row with the current reference_id / employee_id, delete it and re-do the update */
         WHEN OTHERS THEN
           IF (SQLERRM LIKE '%REF_EMP_RE_U_IX%') THEN
             
             DELETE FROM reference_employee 
              WHERE reference_id = referenceIdTable(i)
                AND employee_id = v_new_owner;
            
             UPDATE reference_employee re2
                SET re2.EMPLOYEE_ID = v_new_owner,
                    re2.territory_lov_id = null,
                    re2.UPDATED     = re2.UPDATED,
                    re2.UPDATEDBY   = re2.UPDATEDBY
              WHERE re2.REFERENCE_EMPLOYEE_ID = referenceEmployeeIdTable(i);
              
              DBMS_OUTPUT.put_line('RE_DO for Ref ID: ' || referenceIdTable(i) );
      
          END IF;
       END; 
    END LOOP;

    COMMIT; 
END;

---

/* Oracle Dev Gym March 2 2019 Workout */
CREATE OR REPLACE PROCEDURE proc1
IS
BEGIN
  RAISE NO_DATA_FOUND;  -- D.       -- "line 4" stack 2
END;
/
CREATE OR REPLACE PACKAGE pkg1
IS
  PROCEDURE proc2;
END pkg1;
/
CREATE OR REPLACE PACKAGE BODY pkg1
IS
  PROCEDURE proc2
  IS
  BEGIN
     proc1;  -- C.                -- "line 9" stack 3

  EXCEPTION WHEN OTHERS THEN 
    RAISE VALUE_ERROR;            -- "line 6" stack 1
  END;
END pkg1;
/
CREATE OR REPLACE PROCEDURE proc3
IS
BEGIN
  FOR indx IN 1 .. 1000
  LOOP
     NULL;
  END LOOP;

  pkg1.proc2;  -- B.             -- "line 9" stack 0
END;
/

BEGIN
   proc3;  -- A.
EXCEPTION
  WHEN OTHERS THEN  --                                                                                     STACK
    -- ORA-06502: PL/SQL: numeric or value error                                                             3
    dbms_output.put_line(SQLERRM);
    dbms_output.put_line('------');  
    -- ORA-06502: PL/SQL: numeric or value error ORA-06512: at "SQL_DGIOILDNMDPOSHMACAVWVSKLF.PKG1", line 9  3
    -- ORA-01403: no data found ORA-06512: at "SQL_DGIOILDNMDPOSHMACAVWVSKLF.PROC1", line 4                  2
    -- ORA-06512: at "SQL_DGIOILDNMDPOSHMACAVWVSKLF.PKG1", line 6                                            1
    -- ORA-06512: at "SQL_DGIOILDNMDPOSHMACAVWVSKLF.PROC3", line 9                                           0
    dbms_output.put_line(DBMS_UTILITY.FORMAT_ERROR_STACK );  
    dbms_output.put_line(ASCII(SUBSTR(DBMS_UTILITY.format_error_stack, -1)));  -- 10 (prove linefeed appended)
END;

---

BEGIN
  EXECUTE IMMEDIATE 'CREATE SEQUENCE S_TEST START WITH 1 INCREMENT BY 1';
EXCEPTION
  WHEN OTHERS THEN
--TODO ? :=
    IF SQLCODE = -955 THEN
      NULL; -- suppress specific exception ORA-00955 then keep going
    ELSE
      RAISE;
    END IF;
END; 

-- or
DECLARE
  name_in_use exception; --declare a user defined exception
  pragma exception_init( name_in_use, -955 ); --bind the error code to the above 
BEGIN
  EXECUTE IMMEDIATE 'CREATE SEQUENCE S_TEST START WITH 1 INCREMENT BY 1';
EXCEPTION
  WHEN name_in_use THEN
    NULL; --suppress ORA-00955 exception
END; 

---

-- Run SQL that takes a scalar from a list (cursor) to build its predicate
declare
  i number :=0;
  aid number;
  cursor c1 is 
      SELECT distinct a.account_id
        FROM asp a, asp_approval aa, custom_query_lov_view l
       WHERE a.future_territory_lov_id = aa.future_territory_lov_id
         AND a.future_tsr_owner_id IS NOT NULL
         AND a.future_territory_lov_id IS NOT NULL
         AND a.future_territory_lov_id = l.list_of_values_id
         AND l.custom_level_value in ('NL')
         AND l.value_description not like 'JMP%'
         and account_site_id is null
and rownum<99 ;
begin
  for r in c1 loop
    begin
      dbms_output.put_line(r.account_id);
      
--      SELECT account_id into aid FROM (
--        SELECT a.account_id
--          FROM asp a, account_search asr
--         WHERE a.account_id = r.account_id
--           AND a.account_id = asr.account_id
--           AND (
--                 num_sites != (select count(1)-1 from asp where account_id=r.account_id)
--               or nvl(a.future_sup_account_id,0) != nvl(asr.sup_account_id,0)
--               or nvl(a.future_sup_account_id,0) != nvl(asr.sup_account_id,0)
--               )
--         ORDER BY asr.updated DESC
--      ) WHERE ROWNUM = 1;  -- only check most recent search record
-- same?
      SELECT distinct a.account_id into aid 
          FROM asp a, account_search asr
         WHERE a.account_id = r.account_id
           AND a.account_id = asr.account_id
           AND (
                 num_sites != (select count(1)-1 from asp where account_id=r.account_id)
               or nvl(a.future_sup_account_id,0) != nvl(asr.sup_account_id,0)
               or nvl(a.future_sup_account_id,0) != nvl(asr.sup_account_id,0)
               );
        
      dbms_output.put_line('found '||aid);
      i := i+1;
      
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          null;
    end;
  end loop;

  dbms_output.put_line(i);
end;

---

DECLARE
  bulk_dml_error EXCEPTION;
  PRAGMA EXCEPTION_INIT(bulk_dml_error, -24381);

BEGIN
  ...
  -- We want the PL/SQL runtime engine to execute all DML statements generated by the FORALL, even if one or more than fail with
  -- an error so we add SAVE EXCEPTIONS
  FORALL i IN 1 .. in_assign_table.COUNT SAVE EXCEPTIONS
    EXECUTE IMMEDIATE 'DELETE FROM account_team_assign_all t WHERE t.account_team_assignment_id = :1 AND t.assignment_active = 1'
      USING in_assign_table(i).old_account_team_assignment_id;

...

EXCEPTION 
  WHEN bulk_dml_error THEN 
     FOR ix IN 1 .. SQL%BULK_EXCEPTIONS.COUNT LOOP 
      DBMS_OUTPUT.put_line(SQLERRM(-(SQL%BULK_EXCEPTIONS(ix).ERROR_CODE))); 
    END LOOP; 

---

DECLARE
  TYPE emp_tbl_t IS TABLE OF z_emp%rowtype;
  emp_data emp_tbl_t;

  CURSOR c1 IS
    SELECT * FROM z_emp;

  errorCnt         NUMBER;
  errString        VARCHAR2(4000);
  errCode          NUMBER;
  bulk_dml_errors  EXCEPTION;

  pragma exception_init(bulk_dml_errors, -24381);

BEGIN
  OPEN c1;
  LOOP
    FETCH c1 BULK COLLECT INTO emp_data LIMIT 200;
    EXIT WHEN emp_data.COUNT = 0;
    BEGIN
      DBMS_OUTPUT.PUT_LINE('row count ' || emp_data.COUNT);
      FORALL i IN 1..emp_data.COUNT SAVE EXCEPTIONS
        INSERT INTO z_empbad VALUES emp_data(i);

    EXCEPTION
      WHEN bulk_dml_errors THEN -- now we figure out what failed and why
        errorCnt := SQL%BULK_EXCEPTIONS.COUNT;
        errString := 'Number of statements that failed: ' || TO_CHAR(errorCnt);
        dbms_output.put_line(errString);

        FOR i IN 1..errorCnt LOOP
          IF SQL%BULK_EXCEPTIONS(i).ERROR_CODE > 0 THEN
            errString := CHR(10) ||  'Error #' || i || CHR(10) || 'Error message is ' ||  SQLERRM(-SQL%BULK_EXCEPTIONS(i).ERROR_CODE);
            dbms_output.put_line(errString);
  --      ELSE
  --        errString := CHR(10) || 'Error #' || i || CHR(10) || 'Error message is ' ||  SQLERRM(-SQL%BULK_EXCEPTIONS(i).ERROR_CODE);
  --        dbms_output.put_line(errString);
  --        RAISE;
          END IF;
        END LOOP;  -- exception
    END;
  END LOOP;  -- cursor
END;
--create table z_emp as select * from emp;
--create table z_empbad as select * from z_emp;
-- force a failure to be raised
--alter table z_empbad add constraint  unique_emps UNIQUE (empno);

---

CREATE OR REPLACE TRIGGER zbob_trig
	AFTER UPDATE OR INSERT ON zbob
	FOR EACH ROW
BEGIN
  raise_application_error(-20900,'cannot insert or update row');
  --Unnecessary:
  --rollback;
END;

---

DECLARE
    l_first_name  members.first_name%TYPE := 'Flor';
    l_last_name   members.last_name%TYPE := 'Stone';
    l_rank       members.rank%TYPE := 'Gold';
BEGIN
  INSERT INTO members(first_name, last_name, rank, member_id)
  VALUES(l_first_name, l_last_name, l_rank, l_member_id);
  
  rollback;
  
  EXCEPTION 
    WHEN OTHERS THEN
      DECLARE
          l_error PLS_INTEGER := SQLCODE;
          l_msg VARCHAR2(255) := sqlerrm;
      BEGIN
        CASE l_error 
          WHEN -1 THEN
              -- duplicate rank
              dbms_output.put_line('duplicate rank found ' || l_rank);
              dbms_output.put_line(l_msg);
          WHEN -2291 THEN
              -- parent key not found
              dbms_output.put_line('Invalid customer id ' || l_member_id);
              dbms_output.put_line(l_msg);
        END CASE;
        -- reraise the current exception
        RAISE;
      END;
END;
