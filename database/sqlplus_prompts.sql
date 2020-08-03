
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
