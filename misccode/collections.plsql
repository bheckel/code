-- Treat nested tables like either fixed-size arrays (and use only DELETE) or
-- stacks (and use only TRIM and EXTEND)

---

-- https://www.tutorialspoint.com/plsql/plsql_collections.htm

DECLARE 
   TYPE salary IS TABLE OF NUMBER INDEX BY VARCHAR2(20); 
   salary_list salary; 
   name   VARCHAR2(20); 
BEGIN 
   -- adding elements to the table 
   salary_list('Rajnish') := 62000; 
   salary_list('Minakshi') := 75000; 
   salary_list('Martin') := 100000; 
   salary_list('James') := 78000;  
   
   -- printing the table 
   name := salary_list.FIRST; 
   WHILE name IS NOT null LOOP 
      dbms_output.put_line 
      ('Salary of ' || name || ' is ' || TO_CHAR(salary_list(name))); 
      name := salary_list.NEXT(name); 
   END LOOP; 
END;

---

DECLARE 
   CURSOR c_customers IS 
      select name from customers; 

   TYPE c_list IS TABLE of customers.Name%type INDEX BY binary_integer; 
   name_list c_list; 
   counter integer :=0; 
BEGIN 
   FOR n IN c_customers LOOP 
      counter := counter +1; 
      name_list(counter) := n.name; 
      dbms_output.put_line('Customer('||counter||'):'||name_lis t(counter)); 
   END LOOP; 
END; 
/ 
