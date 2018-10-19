-- SQL> @c:/temp/t.sql
CREATE OR REPLACE PROCEDURE Fire_Emp(Emp_Id NUMBER) AS
BEGIN
  delete from tmpbobh where foon1 = Emp_id;
  commit;
END;
/
-- SQL> EXECUTE FIRE_EMP(67)

---

-- http://st-curriculum.oracle.com/tutorial/DBXETutorial/index.htm

-- An IN parameter passes a constant value from the calling environment to the procedure

-- An OUT parameter passes a value from the procedure to the calling environment.

-- An IN OUT parameter passes a value from the calling environment to the
-- procedure and a possibly different value from the procedure back to the
-- calling environment using the same parameter.

-- Functions and procedures are structured alike. A function must return a
-- value to the calling environment, whereas a procedure returns zero or more
-- values to its calling environment through OUT parameters.

create or replace procedure raise_salary
  (p_id       IN employees.employee_id%TYPE,
   p_percent  IN NUMBER default 0)
is
begin
  update employees
  set salary=salary*(1+p_percent/100)
  where employee_id=p_id
  ;
end raise_salary;
/

execute raise_salary(176,10)

---

-- Use Native Dynamic SQL to pass a record to a procedure that will fill that record based on your parms

CREATE OR REPLACE PACKAGE pkg AUTHID DEFINER AS
 
  TYPE rec IS RECORD (n1 NUMBER, n2 NUMBER);
 
  PROCEDURE p(x OUT rec, y NUMBER, z NUMBER);
END pkg;
/
CREATE OR REPLACE PACKAGE BODY pkg AS
 
  PROCEDURE p(x OUT rec, y NUMBER, z NUMBER) AS
  BEGIN
    x.n1 := y;
    x.n2 := z;
  END p;
END pkg;
/
DECLARE
  r       pkg.rec;
  dyn_str VARCHAR2(3000);
BEGIN
  dyn_str := 'BEGIN pkg.p(:x, 6, 8); END;';
 
  EXECUTE IMMEDIATE dyn_str USING OUT r;
 
  DBMS_OUTPUT.PUT_LINE('r.n1 = ' || r.n1);
  DBMS_OUTPUT.PUT_LINE('r.n2 = ' || r.n2);
END;
/
