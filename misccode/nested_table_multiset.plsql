-- Modified: Fri 28 Jun 2019 15:53:59 (Bob Heckel)

-- Nested tables can be manipulated through an integer index, similar to an
-- associative array, or as a multiset with set operators, such as MULTISET UNION.
--
-- MULTISET operators allow you to perform set-level operations on nested
-- tables, quite similar to the SQL UNION, INTERSECT and MINUS operations.  But
-- with MULTISET, duplicates are preserved unless you specify that want DISTINCT
-- values.

---

CREATE OR REPLACE TYPE parts_nt IS TABLE OF VARCHAR2 (100);

-- Combine two nested tables (won't work for hashes as of 2019)

-- The wrong way:
DECLARE
   l_parts1   parts_nt := parts_nt('Part1', 'Part2', 'Part3');
   l_parts2   parts_nt := parts_nt('Part3', 'Part5', 'Part6');
   l_union    parts_nt;
BEGIN
   l_union := l_parts1;
   l_union.EXTEND(l_parts2.COUNT);

   FOR indx IN 1 .. l_parts2.COUNT
   LOOP
      l_union(indx) := l_parts2(indx);
   END LOOP;

   DBMS_OUTPUT.put_line('Count.Last = ' || l_union.COUNT || '.' || l_union(l_union.LAST));
END;

-- The right way:
DECLARE
   l_parts1   parts_nt := parts_nt('Part1', 'Part2', 'Part3');
   l_parts2   parts_nt := parts_nt('Part3', 'Part5', 'Part6');
   l_union    parts_nt;
BEGIN
   /* l_union := l_parts1 MULTISET UNION DISTINCT l_parts2; */
   l_union := l_parts1 MULTISET UNION l_parts2;
   DBMS_OUTPUT.put_line ('Count.Last = ' || l_union.COUNT || '.' || l_union (l_union.LAST));
END;

/*
Count.Last = 6.Part6
*/

---

DECLARE
  type numbers_t is table of number;

  l_numbers1 numbers_t    := numbers_t(10 , 20 , 30 , 40 , 50);
  l_numbers2 numbers_t    := numbers_t(10 , 20 , 30 , 60, 60, NULL);
  l_numbers  numbers_t;    

BEGIN
  --l_numbers := l_numbers1 multiset union l_numbers2;  -- 10 20 30 40 50 10 20 30 60 60
  -- Unique items only
  --l_numbers := l_numbers1 multiset union distinct l_numbers2;  -- 10 20 30 40 50 60
  -- De-dup the common items
  --l_numbers := set(l_numbers2);  -- 10 20 30 60
  -- On one not on the other
  --l_numbers := l_numbers1 multiset except l_numbers2;  -- 40 50
  -- In both
  l_numbers := l_numbers1 multiset intersect l_numbers2;  -- 10 20 30
  
  for i in l_numbers.first .. l_numbers.last loop
    dbms_output.put_line(l_numbers(i));
  end loop;
  
END;

-- see why fail http://stevenfeuersteinonplsql.blogspot.com/2018/10/why-wont-multiset-work-for-me.html
-- t_task_table := t_task_table multiset union distinct t_task_table
