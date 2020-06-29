-- Adapted: Fri, May 31, 2019  2:08:15 PM (Bob Heckel -- Oracle DevGym) 
CREATE TABLE plch_parts
(
   partnum    INTEGER
 , partname   VARCHAR2 (100)
)
/
BEGIN
   INSERT INTO plch_parts
        VALUES (1, 'Mouse');

   INSERT INTO plch_parts
        VALUES (100, 'Keyboard');

   INSERT INTO plch_parts
        VALUES (500, 'Monitor');

   COMMIT;
END;
/
CREATE OR REPLACE TYPE partnums_t IS TABLE OF INTEGER
/


-- This won't work
CREATE OR REPLACE FUNCTION names_for_parts(list_in IN VARCHAR2)
   RETURN SYS_REFCURSOR
IS
   retval   SYS_REFCURSOR;
BEGIN
   OPEN retval FOR
        SELECT partname
          FROM plch_parts
         WHERE partnum IN (list_in)  -- !!!
      ORDER BY partname;

   RETURN retval;
END names_for_parts;

-- So we try this:
CREATE OR REPLACE FUNCTION names_for_parts (list_in IN VARCHAR2)
   RETURN SYS_REFCURSOR
IS
   retval   SYS_REFCURSOR;
BEGIN
   OPEN retval FOR
         'SELECT partname FROM plch_parts WHERE partnum IN ('
      || list_in
      || ') order by partname';

   RETURN retval;
END names_for_parts;

-- And test it
declare
  list_str varchar2(4000) := '1';
  c sys_refcursor;
begin
  -- Fail!:
  -- ORA-01795: maximum number of expressions in a list is 1000
  for i in 1 .. 1000 loop
    list_str := list_str || ',' || i;
  end loop;
  --dbms_output.put_line(list_str);

  --c := names_for_parts('1,2,3');
  c := names_for_parts(list_str);
end;

-- This works:
CREATE OR REPLACE FUNCTION names_for_parts(list_in IN partnums_t)
   RETURN SYS_REFCURSOR
IS
   retval   SYS_REFCURSOR;
BEGIN
   OPEN retval FOR
        SELECT partname
          FROM plch_parts
         WHERE partnum IN ( SELECT COLUMN_VALUE FROM TABLE(list_in) )
      ORDER BY partname;

   RETURN retval;
END names_for_parts;

declare
  -- Initialize a nested table of integers, not a string of concatenated numbers
  nums partnums_t := partnums_t(1,2,3,4);

  c sys_refcursor;
begin
  
  c := names_for_parts(nums);
end;

-- or to prove the 1000+ threshold is ok:

declare
  -- Initialize nested table of integers, not a string of concatenated numbers
  nums partnums_t := partnums_t();

  c sys_refcursor;
begin
  
  for i in 1 .. 1000 loop
    nums.extend;
    nums(i) := i;
  end loop;

  c := names_for_parts(nums);
end;


-- Also works v10+:
CREATE OR REPLACE FUNCTION names_for_parts(list_in IN partnums_t)
  RETURN SYS_REFCURSOR
IS
   retval   SYS_REFCURSOR;
BEGIN
  OPEN retval FOR
      SELECT partname
        FROM plch_parts
       WHERE partnum MEMBER OF list_in  -- where partnum is an element of the collection (no scanning through the collection required)
    ORDER BY partname;

  RETURN retval;
END names_for_parts;
