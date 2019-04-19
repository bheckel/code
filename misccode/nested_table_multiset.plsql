CREATE OR REPLACE TYPE parts_nt IS TABLE OF VARCHAR2 (100);

-- Combine two nested tables

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
  --l_numbers := l_numbers1 multiset union distinct l_numbers2;  -- 10 20 30 40 50 60
  --l_numbers := set(l_numbers2);  -- 10 20 30 60
  --l_numbers := l_numbers1 multiset except l_numbers2;  -- 40 50
  l_numbers := l_numbers1 multiset union l_numbers2;  -- -- 10 20 30 40 50 10 20 30 60
  
  for i in l_numbers.first .. l_numbers.last loop
    dbms_output.put_line(l_numbers(i));
  end loop;
  
END;
