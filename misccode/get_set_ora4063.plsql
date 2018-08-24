/* https://markhoxey.wordpress.com/2013/09/17/avoiding-ora-04068-existing-state-of-packages-has-been-discarded/ */

create or replace package boboncall_test is

   PROCEDURE set_variable (p_number IN NUMBER);
   
   FUNCTION get_variable
   RETURN NUMBER;

end boboncall_test;


create or replace package body boboncall_test IS

   g_pkg_variable   NUMBER(10);
   foo NUMBER;
   

   PROCEDURE set_variable (p_number IN NUMBER)
   AS
   BEGIN   
      g_pkg_variable := p_number;
   END set_variable;
   
   FUNCTION get_variable
   RETURN NUMBER
   AS
   BEGIN
      RETURN g_pkg_variable;
   END get_variable;

end boboncall_test;
