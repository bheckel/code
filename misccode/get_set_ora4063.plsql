/* https://markhoxey.wordpress.com/2013/09/17/avoiding-ora-04068-existing-state-of-packages-has-been-discarded/ */

create or replace package test_ora04068_types is

  c_str   CONSTANT VARCHAR2(2) := 't1';
  
   -- String constants throw errors - must be in _TYPES
   --c_str   CONSTANT VARCHAR2(2) := 't1';

end test_ora04068_types;
/
create or replace package body test_ora04068_types is
end test_ora04068_types;
/


create or replace package test_ora04068 IS

   -- Numeric constants are OK
   c_num   CONSTANT pls_integer := 2;

   -- String constants throw ORA-04068 - must be moved to _TYPES
   /* c_str   CONSTANT VARCHAR2(2) := 't1'; */

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
     dbms_output.put_line('c_num: ' || c_num || ' c_str: ' || test_ora04068_types.c_str || ' v_body: ' || v_body);
   END set_variable;

end test_ora04068;
/
