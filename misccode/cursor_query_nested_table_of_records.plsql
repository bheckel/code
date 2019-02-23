/* Adapted from https://docs.oracle.com/database/121/LNPLS/static.htm#LNPLS494 */

/* Query a collection */

-- The data type of the collection must either be created at schema level or
-- declared in a package specification:
CREATE OR REPLACE PACKAGE pkg AUTHID DEFINER AS
  TYPE rec IS RECORD(f1 NUMBER, f2 VARCHAR2(30));
  TYPE aa IS TABLE OF rec INDEX BY pls_integer;
END;
/
DECLARE
  collection_of_recs  pkg.aa;
  recs                pkg.rec;

  -- Cursor variable is an SQL query on an associative array of records
  c1 SYS_REFCURSOR;

BEGIN
  -- Load associative array
  collection_of_recs(1).f1 := 1;
  collection_of_recs(1).f2 := 'two';

  OPEN c1 FOR SELECT * FROM TABLE(collection_of_recs);
  FETCH c1 INTO recs;
  CLOSE c1;

  DBMS_OUTPUT.PUT_LINE('Values in record are ' || recs.f1 || ' and ' || recs.f2);
END;
