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
