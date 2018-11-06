DECLARE 
   c_id customers.id%type := 8; 
   c_name customerS.Name%type; 
   c_addr customers.address%type; 
BEGIN 
   SELECT  name, address INTO  c_name, c_addr 
   FROM customers 
   WHERE id = c_id;  
   DBMS_OUTPUT.PUT_LINE ('Name: '||  c_name); 
   DBMS_OUTPUT.PUT_LINE ('Address: ' || c_addr); 

EXCEPTION 
   WHEN no_data_found THEN 
      dbms_output.put_line('No such customer!'); 
   WHEN others THEN 
      dbms_output.put_line(SQLCODE || ':' || SQLERRM || ': ' || DBMS_UTILITY.format_error_backtrace);
      -- Reraising the exception passes it to the enclosing block, which can handle it further
      RAISE;
END;

---

DECLARE 
   c_id customers.id%type := &cc_id; 
   c_name customerS.Name%type; 
   c_addr customers.address%type;  
   -- user defined exception 
   ex_invalid_id  EXCEPTION; 
BEGIN 
   IF c_id <= 0 THEN 
      RAISE ex_invalid_id; 
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
   WHEN no_data_found THEN 
      dbms_output.put_line('No such customer!'); 
   WHEN others THEN 
      dbms_output.put_line('Error!');  
END; 

---

-- Naming Internally Defined Exception
-- Things like NO_DATA_FOUND and TOO_MANY_ROWS have this predefined by the STANDARD package
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
    RAISE_APPLICATION_ERROR(-20000, 'Account past due.');  -- error_code is an integer in the range -20000..-20999 and message is a character string of at most 2048 bytes
  END IF;
END;
/
 
DECLARE
  past_due  EXCEPTION;                       -- declare exception
  PRAGMA EXCEPTION_INIT (past_due, -20000);  -- assign error code to exception
BEGIN
  account_status (TO_DATE('01-JUL-2010', 'DD-MON-YYYY'),
                  TO_DATE('09-JUL-2010', 'DD-MON-YYYY'));   -- invoke procedure

EXCEPTION
  WHEN past_due THEN                         -- handle exception
    DBMS_OUTPUT.PUT_LINE(TO_CHAR(SQLERRM(-20000)));
END;
/
