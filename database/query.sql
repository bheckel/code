set termout off;
set linesize 2000;
set pagesize 9999;

spool c:/temp/query.out;

set serveroutput on;
-------------------------

/* CREATE OR REPLACE PACKAGE test_ora04068_2 */
/* AS */
/*    c_number   CONSTANT NUMBER(5) := 99; */
/* END ; */

/* CREATE OR REPLACE PACKAGE test_ora04068_2 */
/* AS */
/*    c_str   CONSTANT varchar2(5) := 't2'; */
/* END; */

/* BEGIN */
/*    dbms_output.put_line ('Package value is: ' || TO_CHAR(test_ora04068_2.c_str)); */
/* END; */

/* BEGIN */
/*    dbms_output.put_line ('Package value is: ' || TO_CHAR(test_ora04068_2.c_number)); */
/* END; */

/* BEGIN */
/*    dbms_output.put_line ('Package value is: ' || TO_CHAR(test_ora04068_2.c_number)); */
/* END; */

/* BEGIN test_ora04068.set_variable(5); END; */
/* SELECT   distinct OBJECT_NAME */
/*     from dba_procedures --dba_objects */
/*     WHERE OWNER = 'ESTARS' AND OBJECT_TYPE IN( 'PROCEDURE' , 'PACKAGE','FUNCTION') AND procedure_name IS NOT NULL */
/* order BY object_name --, procedure_name; */
select * from user_objects o where object_type != 'JAVA CLASS' and status = 'INVALID';


-------------------------
/

spool off;
quit;
