--  Created: 22-May-2020 (Bob Heckel)
-- Modified: 23-Mar-2023 (Bob Heckel)
-- See also bulk_collect_forall.plsql

---

BEGIN
  FOR rec IN (SELECT contact_id FROM contact WHERE contact_id=9990034351)
  LOOP
     -- There is no NO_DATA_FOUND exception
     DBMS_OUTPUT.put_line (rec.contact_id);
  END LOOP;
END;

---

-- As long as your PL/SQL optimization level is set to 2 (the default) or higher,
-- the compiler will automatically optimize cursor FOR loops to retrieve 100 rows 
-- with each fetch. You cannot modify this number.
...
CURSOR c_dun_nbrs IS
  SELECT aa.duns_nbr FROM account_base ab;
...
BEGIN
	FOR rec IN c_dun_nbrs LOOP
		dbms_output.put_line(rec.duns_nbr);
	END LOOP;
...

---

DECLARE
  v_employees employees%ROWTYPE;
  CURSOR c1 is SELECT * FROM employees;
BEGIN
  OPEN c1;
  -- Fetch entire row into v_employees record:
  FOR i IN 1..10 LOOP
    FETCH c1 INTO v_employees;
    EXIT WHEN c1%NOTFOUND;
    -- Process data here
  END LOOP;
  CLOSE c1;
END;
/

---

DROP TABLE temp;
CREATE TABLE temp (
  emp_no      NUMBER,
  email_addr  VARCHAR2(50)
);
 
DECLARE
  emp_count  NUMBER;
BEGIN
  SELECT COUNT(employee_id) INTO emp_count
  FROM employees;
  
  FOR i IN 1..emp_count LOOP
    INSERT INTO temp (emp_no, email_addr)
    VALUES(i, 'to be added later');
  END LOOP;
END;
/

---

-- Any kind of FOR loop is saying, implicitly, “I am going to execute the loop
-- body for all iterations defined by the loop header” (N through M or SELECT).
-- Conditional exits mean the loop could terminate in multiple ways, resulting in
-- code that is hard to read and maintain.  Use a WHILE loop instead.
DECLARE
   CURSOR plch_parts_cur
   IS
      SELECT * FROM plch_parts;
BEGIN
   FOR rec IN plch_parts_cur
   LOOP
      DBMS_OUTPUT.put_line (rec.partname);
   END LOOP;
END;
/
-- This is better if you only use the "cursor" once
BEGIN
   FOR rec IN (SELECT * FROM plch_parts)
   LOOP
      DBMS_OUTPUT.put_line (rec.partname);
   END LOOP;
END;
/

---

DECLARE
  v_lower  NUMBER := 1;
  v_upper  NUMBER := 1;
BEGIN
  FOR i IN v_lower .. v_upper LOOP
    INSERT INTO foo (ordid, itemid) VALUES (v_ordid, i);
  END LOOP;
END;

---

-- FOR vs. FORALL

DECLARE
  TYPE NumList IS VARRAY(20) OF NUMBER;
  depts NumList := NumList(10, 30, 70);
BEGIN
  FOR i IN depts.FIRST..depts.LAST LOOP
    DELETE FROM employees_temp
    WHERE department_id = depts(i);
  END LOOP;
END;

-- Any failure rolls everything back
DECLARE
  TYPE NumList IS VARRAY(20) OF NUMBER;
  depts NumList := NumList(10, 30, 70);
BEGIN
  FORALL i IN depts.FIRST..depts.LAST  -- no LOOP but only 1 statement allowed!
    DELETE FROM employees_temp
    WHERE department_id = depts(i);
END;

-- Any failure does NOT roll anything back
DECLARE
  TYPE NumList IS VARRAY(20) OF NUMBER;
  depts NumList := NumList(10, 30, 70);
BEGIN
  FORALL i IN depts.FIRST..depts.LAST  -- no LOOP but only 1 statement allowed!
    DELETE FROM employees_temp
    WHERE department_id = depts(i);

  EXCEPTION
    WHEN OTHERS THEN
      DBMS_OUTPUT.PUT_LINE(SQLERRM);
      COMMIT;  -- Commit results of the successful updates prior to this one
      RAISE;
END;

---

DECLARE
  TYPE NumList IS TABLE OF NUMBER;
  depts NumList := NumList(30, 50, 60);
BEGIN
  FORALL j IN depts.FIRST..depts.LAST
    DELETE FROM emp_temp WHERE department_id = depts(j);

  FOR i IN depts.FIRST .. depts.LAST LOOP
    DBMS_OUTPUT.PUT_LINE (
      'Statement #' || i || ' deleted ' ||
      SQL%BULK_ROWCOUNT(i) || ' rows.'
    );
  END LOOP;

  DBMS_OUTPUT.PUT_LINE('Total rows deleted: ' || SQL%ROWCOUNT);
END;
/*
Statement #1 deleted 6 rows.
Statement #2 deleted 45 rows.
Statement #3 deleted 5 rows.
Total rows deleted: 56
*/

---

  FOR i IN 1 .. CASE p_mom.species
                  WHEN 'RABBIT' THEN 12
                  WHEN 'DOG' THEN 4
                  WHEN 'KANGAROO' THEN 1
                END
  LOOP

---

-- Use hardcoded temporary table. Toggle BULK/no BULK loop.
--  set serveroutput on size 500000
declare
  cnt number := 0;

  cursor c1 is
    with v as (
    select 4193628 aid, 11825450 actid from dual
    union
    select 10660140 aid, 12965780 actid from dual
--    union
--    select 3491687 aid,  12999780 actid from dual
--    union
--    select 3491687 aid,  12999800 actid from dual
  ), v2 as ( 
     select a.account_id,t.activity_id, t.employee_id, t.due_date, t.number_of_hours, t.status, t.task_id, t.contact_id, t.start_date,t.end_date,
            t.employee_id oldlead,ate.employee_id newleadandtsr, t.outcome_lov_id
       from task t
       join activity_search act_s on t.activity_id = act_s.activity_search_id
       left join ACTIVITY ACT on T.ACTIVITY_ID = ACT.ACTIVITY_ID
       left join contact c on act.contact_id = c.contact_id
       left join account_name a_n on c.account_name_id = a_n.account_name_id
       left join account a on a_n.account_id = a.account_id
       left join contact_search cs on c.CONTACT_ID = cs.contact_search_id
       left join account_team_assign_all ata on a.account_id= ata.account_id
       left join account_team_employee ate on ata.account_team_id=ate.account_team_id and ate.function_lov_id = 2750
     where T.CURRENT_TASK = 1 and (c.USEDINESTARS = 1 or c.type = 'S')
  )
  select distinct v2.*
    from v, v2
   where v.aid=v2.account_id and v.actid=v2.activity_id;
 
  type t_c1 is table of c1%rowtype;
  c1table t_c1;
begin
  open c1;
  --LOOP
    fetch c1 bulk collect into c1table;--LIMIT 5;
    --EXIT WHEN c1table.COUNT = 0;
    for i in 1 .. c1table.count loop
      DBMS_OUTPUT.put_line(c1table(i).account_id);
      
      UPDATE TASK_BASE T
         SET T.end_date = sysdate,
             T.current_task = 0,
             T.new_task = 0,
             T.outcome = NULL,
             T.updatedby = 0,
             T.updated = sysdate,
             T.audit_source = 'RION-63332'
       WHERE T.task_id = c1table(i).task_id
         AND T.employee_id = c1table(i).oldlead;
         
      INSERT INTO TASK_BASE
        (TASK_ID,
         ACTIVITY_ID,
         EMPLOYEE_ID,
         DUE_DATE,
         NUMBER_OF_HOURS,
         STATUS,
         CREATED,
         CREATEDBY,
         UPDATED,
         UPDATEDBY,
         NEW_TASK,
         ORIGIN_TASK_ID,
         CURRENT_TASK,
         OUTCOME_LOV_ID,
         CONTACT_ID,
         START_DATE,end_date,
         OWNER_TERRITORY_LOV_ID,
         AUDIT_SOURCE)
      VALUES
        (UID_TASK.NEXTVAL,
         c1table(i).activity_id,
         c1table(i).newleadandtsr,
         c1table(i).due_date,
         c1table(i).number_of_hours,
         c1table(i).status,
         sysdate,--created
         0,
         sysdate,--updated
         0,
         1, --new_task
         c1table(i).task_id, -- old tid (origin)
         1, --current task
         c1table(i).outcome_lov_id,
         c1table(i).contact_id,
         c1table(i).start_date,
         c1table(i).end_date,
         (select territory_lov_id from employee_base e where e.employee_id = 213000 ),
         'RION-63332'
      );
      cnt := cnt + sql%rowcount;
      rollback;
    end loop;  -- DML loop
  --END LOOP;  -- LIMIT loop
  DBMS_OUTPUT.put_line('cnt:'||cnt);
  close c1;
end;
