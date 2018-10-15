-- https://docs.oracle.com/database/121/LNPLS/dynamic.htm#LNPLS01115

CREATE OR REPLACE PROCEDURE plch_change_table AUTHID DEFINER
IS
BEGIN
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

DECLARE
  plsql_block VARCHAR2(500);
  new_deptid  NUMBER(4);  /* appears as  'deptid IN OUT NUMBER,'  in its PROCEDURE's parms */
  new_dname   VARCHAR2(30) := 'Advertising';
  new_mgrid   NUMBER(6)    := 200;
BEGIN
  -- Dynamic PL/SQL block invokes subprogram:
  plsql_block := 'BEGIN create_dept(:a, :b, :c); END;';

 /* Specify bind variables in USING clause.
    Specify mode for first parameter.
    Modes of other parameters are correct by default. */

  EXECUTE IMMEDIATE plsql_block
    USING IN OUT new_deptid, new_dname, new_mgrid;
END;
