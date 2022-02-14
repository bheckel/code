-- Modified: 10-Feb-2022 (Bob Heckel)
-- https://docs.oracle.com/database/121/LNPLS/dynamic.htm#LNPLS01115
-- See also run_all_procedures.plsql, using.plsql bulk_collect_forall.plsql

-- The EXECUTE IMMEDIATE statement is typically used for DDL, single-row SELECTs, and other DML.
-- The OPEN FOR, FETCH, and CLOSE statements support dynamic multirow queries.

-- To process dynamic SQL statements, you use EXECUTE IMMEDIATE or OPEN-FOR / FETCH / CLOSE statements.
-- EXECUTE IMMEDIATE is used for a single-row SELECT statement, all DML statements, and DDL statements,
-- whereas OPEN-FOR / FETCH / CLOSE statements are used for multirow SELECT statements and reference
-- cursors.

-- For dynamic SQL, always use native dynamic SQL except when its functionality is insufficient; only 
-- then, use the DBMS_Sql API. For select, insert, update, delete, and merge statements, native dynamic 
-- SQL is insufficient when the SQL statement has placeholders or select list items that are not known 
-- at compile time.

---

-- When designing your programs, keep in mind that executing DDL like this will automatically commit any pending transaction
begin EXECUTE IMMEDIATE 'TRUNCATE TABLE foo'; end;

---

begin
  for r in ( select table_name from user_tables where table_name like 'MKC_REVENUE2_%2JUL21' ) loop
    DBMS_OUTPUT.put_line(r.table_name);
    execute immediate 'drop table ' || r.table_name || ' purge';
  end loop;
end; 

---

-- Prove that NO_DATA_FOUND is triggered when using EXECUTE IMMEDIATE
declare
  l_staged_team  NUMBER;

begin
  EXECUTE IMMEDIATE 'SELECT account_team_id FROM ASP_DFLT_TSR_OWN_TEAM WHERE future_tsr_owner_id = :1'
    INTO l_staged_team
    USING 1234;

  IF l_staged_team IS NOT NULL THEN
    dbms_output.put_line('ok');
  ELSE
    dbms_output.put_line('unreachable');
  END IF;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      dbms_output.put_line('NO_DATA_FOUND');
end;

---

CREATE OR REPLACE PROCEDURE plch_change_table AUTHID DEFINER
IS
BEGIN
   -- Native "dynamic" SQL
   -- The ALTER statement is not supported by embedded SQL and so the use of a
   -- method where the PL/SQL compiler does not analyze the SQL statement is mandated
   EXECUTE IMMEDIATE 'alter table plch_trees modify tree_name varchar2(10)';

   EXECUTE IMMEDIATE
      q'[
          BEGIN
						INSERT INTO plch_trees (id, tree_name, tree_location) VALUES (100, 'Black Oak', 'Eastern US');
						INSERT INTO plch_trees (id, tree_name, tree_location) VALUES (200, 'Tamarack', 'Europe');
						COMMIT;
					END;
        ]';
END;
/

---

CREATE OR REPLACE PROCEDURE create_dept (
  deptid IN OUT NUMBER,
  dname  IN     VARCHAR2,
  mgrid  IN     NUMBER,
  locid  IN     NUMBER
) AUTHID DEFINER AS
BEGIN
  deptid := departments_seq.NEXTVAL;

  INSERT INTO departments (
    department_id,
    department_name,
    manager_id,
    location_id
  )
  VALUES (deptid, dname, mgrid, locid);
END;
/
DECLARE
  dyn_stmt   VARCHAR2(4000);
  new_deptid NUMBER(4);  /* defined as 'deptid IN OUT NUMBER' in its PROCEDURE's parms */
  new_dname  VARCHAR2(30) := 'Advertising';
  new_mgrid  NUMBER(6)    := 200;
BEGIN
  -- Dynamic PL/SQL block invokes subprogram:
  dyn_stmt := 'BEGIN create_dept(:a, :b, :c); END;';

 /* Specify bind variables in USING clause.
  * Specify mode for first parameter.
  * Modes of other parameters are correct by default.
  */
  EXECUTE IMMEDIATE dyn_stmt
    USING IN OUT new_deptid, new_dname, new_mgrid;
END;

---

DECLARE
  this_is_a_null  CHAR(1);  -- Set to NULL automatically at run time
BEGIN
  EXECUTE IMMEDIATE 'UPDATE employees_temp SET commission_pct = :x'
    USING this_is_a_null;
END;
/

---

SET SERVEROUTPUT ON
DECLARE
	sql_stmt     VARCHAR2(200);
	v_student_id NUMBER := &sv_student_id;
	v_first_name VARCHAR2(25);
	v_last_name  VARCHAR2(25);

BEGIN
	sql_stmt := 'SELECT first_name, last_name'||
							' FROM student' ||
							' WHERE student_id = :1';

	EXECUTE IMMEDIATE sql_stmt
     INTO v_first_name, v_last_name
		USING v_student_id;
END;

---

EXECUTE IMMEDIATE q'[
  CREATE INDEX "SETARS"."ZSP_DETAILS_ACCT_ID_SITE_ID_IX" ON "SETARS"."ZASP_DETAILS" ("ACCOUNT_SITE_ID", "ACCOUNT_ID") 
]';

---

-- Execute DDL based on a query
DECLARE
  l_sql       VARCHAR2(4000);

  CURSOR aspCursor IS
    select 'CREATE INDEX ' || ucc.table_name || 'XX_IX on ' || ucc.table_name || '(' || ucc.column_name || ')' index_create
	    from user_constraints uc, user_cons_columns ucc
     where uc.constraint_name = ucc.constraint_name
       and uc.constraint_type = 'R'
       and not exists (select 1
                         from user_ind_columns uic
                        where uic.TABLE_NAME = uc.table_name
                          and uic.COLUMN_NAME = ucc.column_name);
BEGIN
  FOR aspRec IN aspCursor LOOP
    l_sql := aspRec.index_create;

    EXECUTE IMMEDIATE l_sql;
  END LOOP;
 
  EXCEPTION
    WHEN OTHERS THEN
      DBMS_OUTPUT.put_line(l_sql || ' FAILED! ' || sqlerrm);
END;

---

...
    t_task_id_table           ASP_PKG_TYPES.numberTable;
    t_activity_id_table       ASP_PKG_TYPES.numberTable;
    t_old_lead_owner_id_table ASP_PKG_TYPES.numberTable;
    t_new_lead_owner_id_table ASP_PKG_TYPES.numberTable;
    t_due_date_table          ASP_PKG_TYPES.dateTable;
    t_number_of_hours_table   ASP_PKG_TYPES.numberTable;
    t_status_table            ASP_PKG_TYPES.varcharTable;
    t_outcome_table           ASP_PKG_TYPES.varcharTable;
    t_origin_table            ASP_PKG_TYPES.varcharTable;
    t_category_table          ASP_PKG_TYPES.varcharTable;
    t_origin_task_id_table    ASP_PKG_TYPES.numberTable;
    t_outcome_lov_id_table    ASP_PKG_TYPES.numbertable;
    t_contact_id_table        ASP_PKG_TYPES.numbertable;
    t_terr_id_table           ASP_PKG_TYPES.numbertable;
    ...
begin
  ...
      FORALL i IN 1 .. in_task_table.COUNT SAVE EXCEPTIONS EXECUTE IMMEDIATE
         'UPDATE TASK_BASE T
             SET T.END_DATE = :1,
             T.CURRENT_TASK = 0,
             T.NEW_TASK = 0,
             T.OUTCOME = NULL,
             T.Updatedby = 0,
             T.Updated = :2,
             T.Outcome_Lov_Id = :3
          WHERE T.TASK_ID = :4 
            AND T.EMPLOYEE_ID != :5
          RETURNING TASK_ID,
                    ACTIVITY_ID, 
                    :6, 
                    DUE_DATE, 
                    NUMBER_OF_HOURS,
                    STATUS,
                    OUTCOME,
                    ORIGIN,
                    CATEGORY,
                    ORIGIN_TASK_ID,
                    OUTCOME_LOV_ID,
                    CONTACT_ID INTO :7, :8, :9, :10, :11, :12, :13, :14, :15, :16, :17, :18'
         USING v_start_time,
               v_start_time,
               in_task_table(i).outcome_lov_id,
               in_task_table(i).task_id,
               in_task_table(i).new_employee_id,
               in_task_table(i).new_employee_id
         RETURNING BULK COLLECT INTO t_task_id_table,
         t_activity_id_table, t_new_lead_owner_id_table,
         t_due_date_table, t_number_of_hours_table,
         t_status_table, t_outcome_table, t_origin_table,
         t_category_table, t_origin_task_id_table,
         t_outcome_lov_id_table, t_contact_id_table
         ;

...

  FOR i IN 1 .. t_task_id_table.COUNT LOOP
    dbms_output.put_line('UPDATE TASK_BASE SET OWNER_TERRITORY_LOV_ID = (select territory_lov_id from employee_base where employee_id = ' || t_new_lead_owner_id_table(i) || ') WHERE task_id = ' || t_task_id_table(i));
  END LOOP;

  FORALL i IN 1 .. t_task_id_table.COUNT SAVE EXCEPTIONS EXECUTE IMMEDIATE
    'UPDATE TASK_BASE SET OWNER_TERRITORY_LOV_ID = (select territory_lov_id from employee_base where employee_id = :1)  WHERE task_id = :2'
      USING t_new_lead_owner_id_table(i), t_task_id_table(i);

---

-- Using BULK COLLECT with native dynamic SQL queries that might return more than one row:

DECLARE
   TYPE ids_t IS TABLE OF employees.employee_id%TYPE;
   l_ids   ids_t;
BEGIN
   EXECUTE IMMEDIATE 'SELECT employee_id FROM employees WHERE department_id = :dept_id'
      BULK COLLECT INTO l_ids
      USING 123;

   FOR indx IN 1 .. l_ids.COUNT LOOP
      DBMS_OUTPUT.put_line('selected employee ' || l_ids(indx));
   END LOOP;
END;

-- compare

DECLARE
   TYPE ids_t IS TABLE OF employees.employee_id%TYPE;
   l_ids ids_t;
BEGIN
   EXECUTE IMMEDIATE 'UPDATE employees SET last_name = UPPER(last_name) WHERE department_id = 100 RETURNING employee_id INTO :ids'
		 RETURNING BULK COLLECT INTO l_ids;
   
   FOR indx IN 1 .. l_ids.COUNT LOOP
      DBMS_OUTPUT.PUT_LINE('updated employee ' || l_ids(indx));
   END LOOP;
END;

---

    EXECUTE IMMEDIATE 'update opportunity_BASE o set (' || tbl_cols ||
                      ') = (select ' || tbl_cols ||
                      ' from opportunity_hist o where opportunity_id = :1 and h_version = :2) ' ||
                      'where opportunity_id = :3'
      USING ID, source_h_version, ID;

    IF (SQL%ROWCOUNT = 1) THEN
      DBMS_OUTPUT.put_line('Record ' || ID ||
                           ' Updated, Current H_VERSION = ' ||
                           TO_CHAR(l_h_version + 1));
    ELSE
      ROLLBACK;
      DBMS_OUTPUT.put_line('Invalid SQL, incorrect number of records updated');
    END IF;

---

DECLARE
  new_sal NUMBER := 75000;
BEGIN
  sql_stmt := 'UPDATE emp SET salary = :new_sal WHERE emp_id = :empno';

  EXECUTE IMMEDIATE sql_stmt USING new_sal, 123;
...

-- same
DECLARE
  new_sal NUMBER := 75000;
BEGIN
  UPDATE emp SET salary = new_sal WHERE emp_id = 123;
...

