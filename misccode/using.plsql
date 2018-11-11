--https://docs.oracle.com/database/121/LNPLS/dynamic.htm#LNPLS01108
CREATE PROCEDURE calc_stats(w NUMBER, x NUMBER, y NUMBER, z NUMBER) IS
BEGIN
  DBMS_OUTPUT.PUT_LINE(w + x + y + z);
END;
/
DECLARE
  a NUMBER := 4;
  b NUMBER := 7;
  plsql_block VARCHAR2(100);
BEGIN
  plsql_block := 'BEGIN calc_stats(:x, :x, :y, :x); END;';
  EXECUTE IMMEDIATE plsql_block USING a, b;  -- calc_stats(a, a, b, a)
END;
/
DROP PROCEDURE calc_stats;
