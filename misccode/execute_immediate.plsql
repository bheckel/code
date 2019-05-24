-- https://docs.oracle.com/database/121/LNPLS/dynamic.htm#LNPLS01115
-- See also run_all_procedures.plsql, using.plsql

-- To process dynamic SQL statements, you use EXECUTE IMMEDIATE or OPEN-FOR / FETCH / CLOSE statements.
-- EXECUTE IMMEDIATE is used for a single-row SELECT statement, all DML statements, and DDL statements,
-- whereas OPEN-FOR / FETCH / CLOSE statements are used for multirow SELECT statements and reference
-- cursors.

-- For dynamic SQL, always use native dynamic SQL except when its functionality is insufficient; only 
-- then, use the DBMS_Sql API. For select, insert, update, delete, and merge statements, native dynamic 
-- SQL is insufficient when the SQL statement has placeholders or select list items that are not known 
-- at compile time

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
