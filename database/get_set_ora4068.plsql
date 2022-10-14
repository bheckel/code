-- Modified: 11-Oct-2022 (Bob Heckel)
-- https://markhoxey.wordpress.com/2013/09/17/avoiding-ora-04068-existing-state-of-packages-has-been-discarded/ 

-- Example failure:

-- disconnect
--  set serveroutput on size 500000
CREATE OR REPLACE PACKAGE pkg_state AS
  PROCEDURE set_variable(p_number IN NUMBER);
  FUNCTION get_variable RETURN NUMBER;
END pkg_state;
/
CREATE OR REPLACE PACKAGE BODY pkg_state AS
  g_pkg_variable NUMBER(10);  -- this needs to go into a new PKG_STATE_TYPES package spec
  
  PROCEDURE set_variable (p_number IN NUMBER) AS
  BEGIN
    g_pkg_variable := p_number;
  END set_variable;
  
  FUNCTION get_variable RETURN NUMBER AS
  BEGIN
    RETURN g_pkg_variable;
  END get_variable;
END pkg_state;
/
EXEC pkg_state.set_variable(5);
SELECT pkg_state.get_variable FROM dual;--5

  -- then in another session, pretending to be a developer
  ALTER PACKAGE pkg_state COMPILE BODY;
  SELECT pkg_state.get_variable FROM dual;--no problem

-- Back in user session
SELECT pkg_state.get_variable FROM dual;--ORA-04068: existing state of packages has been discarded
SELECT pkg_state.get_variable FROM dual;--null

-- So we cannot make code changes without interfering with sessions that are currently using the package.

drop package pkg_state;

---

create or replace package test_ora04068_TYPES is

  c_str   CONSTANT VARCHAR2(2) := 't1';
  
end test_ora04068_TYPES;
/
create or replace package body test_ora04068_TYPES is
end test_ora04068_TYPES;
/


create or replace package test_ora04068 IS

   -- Strings and sring constants throw ORA-04068 - must be moved to _TYPES
   /* c_str   CONSTANT VARCHAR2(2) := 't1'; */

   -- Numeric CONSTANTs are OK
   c_num   CONSTANT pls_integer := 2;

   -- But numeric constants with calculations are not
   /* c_calc CONSTANT := power(2,32); */
   -- Must instead use
   c_calc CONSTANT := 4294967296;

  PROCEDURE set_variable (in_number IN NUMBER);

end test_ora04068;
/
create or replace package body test_ora04068 IS

   PROCEDURE set_variable(in_number IN NUMBER)
   AS

   v_body PLS_INTEGER;

   BEGIN
     v_body := in_number;

     -- No session error
     dbms_output.put_line('c_num: ' || c_num || ' c_str: ' || test_ora04068_TYPES.c_str || ' v_body: ' || v_body);
   END set_variable;

end test_ora04068;
/
