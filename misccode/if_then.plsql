BEGIN
  IF 1 = 1 THEN
    DBMS_OUTPUT.PUT_LINE ('x');
  END IF;
END;

---

SET serveroutput on;

DECLARE
  v_prod  samp.prod_nm%TYPE := 'Zofran Tablets';
  v_samp  NUMBER(10);
  v_sd    DATE;
BEGIN
  -- Must return exactly 1 record for SELECTs
  SELECT prod_nm, samp_id, storage_dt
  -- Must align with SELECT statement
  INTO   v_prod, v_samp, v_sd
  FROM   samp
  --      db           db or PL/SQL
  WHERE prod_nm = v_prod and samp_id=184316;
  
  DBMS_OUTPUT.PUT_LINE ('The value of v_sd is '
			 ||v_sd || ' rows '|| SQL%ROWCOUNT );
  
  IF v_prod = 'Zofran Tablets' THEN
    DBMS_OUTPUT.PUT_LINE ('x');
  ELSIF v_prod = 'yyz' THEN
    DBMS_OUTPUT.PUT_LINE ('y');
  ELSE
    DBMS_OUTPUT.PUT_LINE ('z');
  END IF;
END;
/	
