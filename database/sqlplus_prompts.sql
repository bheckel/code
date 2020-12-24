-------------------------------------
-- Modified: 24-Dec-2020 (Bob Heckel)
-------------------------------------

-- Run these by hand first:
-- SQL> set DEFINE ON
-- SQL> set serveroutput on size unl
-- SQL> DEFINE doAll = '&1'

-- SQL> @c:\cygwin64\home\heck\code\misccode\sqlplus_prompts.sql
BEGIN
  dbms_output.put_line('Do all = &doAll');
  if ( '&doAll' in ('y','Y','YES') ) then
    dbms_output.put_line('ok');
  end if;
END;
/

---

var v1  VARCHAR2(50);

--exec :v1 := 'JUSTICE';
exec :v1 := '&prompt';
  
DECLARE
  myv   VARCHAR2(50);
BEGIN
  myv := :v1;
  DBMS_OUTPUT.put_line(myv);
END;
