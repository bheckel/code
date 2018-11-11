/* https://docs.oracle.com/database/121/LNPLS/static.htm#LNPLS494 */
CREATE OR REPLACE PACKAGE pkg AUTHID DEFINER AS
  TYPE myrec IS RECORD( f1 NUMBER,
                      f2 VARCHAR2(30) );

  TYPE mytab IS TABLE OF myrec INDEX BY pls_integer;
END;

DECLARE
  nt1 pkg.mytab;  -- collection of records
  nt2 pkg.myrec;

  c1 SYS_REFCURSOR;  -- weakly typed
BEGIN
  nt1(1).f1 := 1;
  nt1(1).f2 := 'one';

  OPEN c1 FOR SELECT * FROM TABLE(nt1);
  FETCH c1 INTO nt2;
  CLOSE c1;

  DBMS_OUTPUT.PUT_LINE('Values in record are ' || nt2.f1 || ' and ' || nt2.f2);
END;
/
