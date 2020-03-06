/* https://markhoxey.wordpress.com/2013/09/17/avoiding-ora-04068-existing-state-of-packages-has-been-discarded/ */

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
