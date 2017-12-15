-- SQL*Plus host variables (max length for PL/SQL is 30)
VARIABLE g_char VARCHAR2(30);
VARIABLE g_num  NUMBER;
VARIABLE g_date VARCHAR2(30);


DECLARE
  -- PL/SQL variables:
  v_char VARCHAR2(30);
  v_num  NUMBER;
  v_tmp  VARCHAR2(30);
  ----v_date VARCHAR2(30);
  v_date DATE;
BEGIN
  v_char := '42 is the answer';
  v_num  := TO_NUMBER(SUBSTR(v_char, 1, 2));
  v_tmp  := 'May 21, 1998';
  v_date := TO_DATE(v_tmp, 'Month DD, YYYY');
  :g_char := v_char;
  :g_num  := v_num;
  :g_date := v_date;
END;
/

PRINT g_char
PRINT g_num
-- Date is output like this: 21-MAY-98
PRINT g_date
