-- Use a comma-separated list like a table

SELECT ids, ab.account_id 
FROM (WITH DATA AS
      (SELECT '432803,434768,439324' ids FROM dual)
      SELECT to_number(TRIM(regexp_substr(ids, '[^,]+', 1, LEVEL))) ids
      FROM DATA
      CONNECT BY instr(ids, ',', 1, LEVEL - 1) > 0) csv
LEFT JOIN account_base ab ON csv.ids=ab.account_id

---

WITH DATA AS
  (SELECT '409065,93254,1000493402,133485,1002200674,1002686682' ids FROM dual)
SELECT trim(COLUMN_VALUE) ids
FROM DATA, xmltable(('"' || REPLACE(ids, ',', '","') || '"'))
