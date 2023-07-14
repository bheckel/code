
PROCEDURE REFRESH_EMP_EMAIL_TBL IS
  l_cnt  NUMBER := 0;
BEGIN 
  SELECT count(1)
    INTO l_cnt
    FROM user_tables 
   WHERE table_name = 'EMP_EMAIL';

  IF l_cnt > 0 THEN
    EXECUTE IMMEDIATE 'DROP TABLE EMP_EMAIL';
  END IF;
...    
