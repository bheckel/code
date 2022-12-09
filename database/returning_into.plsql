--  Created: 23-Apr-2019 (Bob Heckel) 
-- Modified: 08-Dec-2022 (Bob Heckel)
--
-- See also insert_new_record_correlated.sql

-- When you need to get info back after a DML operation without an extra context switch like this:
DECLARE 
   l_num   PLS_INTEGER; 
BEGIN 
   UPDATE parts 
      SET part_name = UPPER(part_name) 
    WHERE part_name LIKE 'K%'; 
 
   SELECT part_number 
     INTO l_num 
     FROM parts 
    WHERE part_name = UPPER(part_name); 
 
   DBMS_OUTPUT.put_line(l_num); 
END;

-- Plus RETURNING is read-consistent, whereas if you do an update and then a select as shown above, 
-- that query could potentially return freshly committed rows from other sessions that you *didn't* 
-- touch in the update

-- One record:
DECLARE 
   l_num   PLS_INTEGER; 
BEGIN 
      UPDATE parts 
         SET part_name = UPPER(part_name) 
       WHERE part_name LIKE 'K%' 
   RETURNING part_number 
        INTO l_num; 
 
   DBMS_OUTPUT.put_line(l_num); 
END;

-- Multiple records:
DECLARE 
   l_part_numbers   DBMS_SQL.number_table; 
BEGIN 
      UPDATE parts 
         SET part_name = part_name || '1' 
   RETURNING part_number 
        BULK COLLECT INTO l_part_numbers; 
 
   FOR i IN 1 .. l_part_numbers.COUNT LOOP 
      DBMS_OUTPUT.put_line(l_part_numbers(i)); 
   END LOOP; 
END;

---

/* https://docs.oracle.com/database/121/LNPLS/composites.htm#LNPLS1414 */

-- One record:
DECLARE
  TYPE EmpRec IS RECORD (
    last_name  employees.last_name%TYPE,
    salary     employees.salary%TYPE
  );

  myemp EmpRec;

BEGIN
	-- Use the RETURNING clause to retrieve details from the employee's modified
  -- row (i.e. row(s) affected by -- DML statements), within the same context switch
  -- used to execute the UPDATE statement
  UPDATE employees
    SET salary = salary * 1.1
    WHERE employee_id = 100
    RETURNING last_name, salary INTO myemp;
 
  DBMS_OUTPUT.PUT_LINE (
    'Salary of ' || myemp.last_name || ' raised from ' ||
    old_salary || ' to ' || myemp.salary
  );
END;
/

---

-- Multiple records
CREATE TABLE plch_parts
(
   partnum    INTEGER
 , partname   VARCHAR2 (100)
);

BEGIN
   INSERT INTO plch_parts VALUES (1, 'Mouse');
   INSERT INTO plch_parts VALUES (100, 'Keyboard');
   INSERT INTO plch_parts VALUES (500, 'Monitor');
   COMMIT;
END;

--delete from plch_parts

--select partname from plch_parts WHERE partname LIKE 'M%'

DECLARE
   type nt_t is table of plch_parts.partnum%type;
   nt nt_t;
BEGIN
      UPDATE plch_parts
         SET partname = UPPER (partname)
       WHERE partname LIKE 'M%'
   RETURNING partnum BULK COLLECT INTO nt;  -- must bulk collect

  for i in nt.first .. nt.last loop
     DBMS_OUTPUT.put_line ('x ' || nt(i)) ;
  end loop;

  rollback;
END;

---

-- Aggregated return value
DECLARE
   l_num   PLS_INTEGER;
BEGIN
  UPDATE plch_parts
     SET partname = UPPER (partname)
   WHERE partname LIKE 'M%'
   --RETURNING count(1) INTO l_num;
   RETURNING sum(partnum) INTO l_num;

   DBMS_OUTPUT.put_line (l_num) ;
	commit;
END;

---

-- http://stevenfeuersteinonplsql.blogspot.com/2019/04/use-returning-clause-to-avoid.html
-- Dynamic

DECLARE  
   l_part_number   parts.part_number%TYPE;  
BEGIN  
   EXECUTE IMMEDIATE 
   q'[UPDATE parts  
         SET part_name = part_name || '1' 
       WHERE part_number = 100 
      RETURNING part_number INTO :one_pn]'
   RETURNING INTO l_part_number;  
  
   DBMS_OUTPUT.put_line(l_part_number);   
END;

DECLARE  
   l_part_numbers   DBMS_SQL.number_table;  
BEGIN  
   EXECUTE IMMEDIATE 
   q'[UPDATE parts  
         SET part_name = part_name || '1' 
      RETURNING part_number INTO :pn_list]'
   RETURNING BULK COLLECT INTO l_part_numbers;  
  
   FOR i IN 1 .. l_part_numbers.COUNT  LOOP  
      DBMS_OUTPUT.put_line(l_part_numbers(i));  
   END LOOP;  
END;

---

declare
  x number;
begin
  INSERT INTO note_base (note_id, subject, type, note, created, createdby, updatedby) 
                 VALUES (uid_note.NEXTVAL , 'Person Left Company', 'Status', 'Set to GONE on December 1, 2022', SYSDATE, 0, 0) 
  returning note_id into x
  ;

  dbms_output.put_line(x);

  INSERT INTO contact_note (contact_note_id, contact_id, note_id, created, createdby, updatedby, original_contact_id)
                    VALUES (uid_contact_note.NEXTVAL, 860664, x, SYSDATE, 0, 0, 860664)
  ;

  commit;
end;
