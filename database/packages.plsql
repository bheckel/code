-----------------------------------------
--  Created: Mon 01-Feb-2019 (Bob Heckel) 
-- Modified: Thu 04-Feb-2021 (Bob Heckel)
-----------------------------------------

-- Generic package template
CREATE OR REPLACE PACKAGE mypkg AS
  PROCEDURE myproc;
END mypkg;
/
CREATE OR REPLACE PACKAGE BODY mypkg AS
  PROCEDURE myproc
  IS
    x NUMBER DEFAULT 0;
  BEGIN
    DBMS_OUTPUT.put_line('ok');
  END;
END mypkg;

---

CREATE OR REPLACE PACKAGE testpkg AS
  PROCEDURE testproc(in_x NUMBER);
END testpkg;
/
CREATE OR REPLACE PACKAGE BODY testpkg AS
  PROCEDURE testproc(in_x NUMBER) IS
    l_now DATE := sysdate;

    CURSOR c IS
      select dummy from dual;

  BEGIN
    IF in_x = 42 THEN
      FOR r IN c LOOP
        dbms_output.put_line('ok1 ' || r.dummy);
      END LOOP;
    END IF;

    SELECT sysdate 
      INTO l_now
      FROM DUAL;

    dbms_output.put_line('ok2 ' || l_now);

  END;
END testpkg;
/

exec testpkg.testproc(42);
drop package testpkg;

---

CREATE OR REPLACE PACKAGE manage_students AS
  PROCEDURE find_sname(i_student_id IN student.student_id%TYPE,
                       o_first_name OUT student.first_name%TYPE,
                       o_last_name OUT student.last_name%TYPE);

  FUNCTION id_is_good(i_student_id IN student.student_id%TYPE) RETURN BOOLEAN;

END manage_students;
/
CREATE OR REPLACE PACKAGE BODY manage_students AS
  PROCEDURE find_sname (i_student_id IN student.student_id%TYPE,
                        o_first_name OUT student.first_name%TYPE,
                        o_last_name OUT student.last_name%TYPE)
  IS
    v_student_id student.student_id%TYPE;

  BEGIN
    SELECT first_name, last_name
    INTO o_first_name, o_last_name
    FROM student
    WHERE student_id = i_student_id;

    EXCEPTION
			WHEN OTHERS THEN
			DBMS_OUTPUT.PUT_LINE ('Error in finding student_id: '||v_student_id);
  END find_sname;

   FUNCTION id_is_good(i_student_id IN student.student_id%TYPE) RETURN BOOLEAN
   IS
	 v_id_cnt number;

	 BEGIN
		 SELECT COUNT(*)
		 INTO v_id_cnt
		 FROM student
		 WHERE student_id = i_student_id;
		 RETURN 1 = v_id_cnt;

		 EXCEPTION
	 WHEN OTHERS THEN
		 RETURN FALSE;
 END id_is_good;

END manage_students;

---

create or replace package ORION_ERRORS_TEST is

  procedure proc_a;
  procedure proc_b;
  procedure proc_c;
  
  procedure force_err(in_status VARCHAR2);

end ORION_ERRORS_TEST;
/
create or replace package body ORION_ERRORS_TEST is

  procedure proc_c is
    begin
     dbms_output.put_line('Inside procedure c');
     orion_errors.raise_error(orion_errors.MY_USER_DEFINED_ERROR);
  end proc_c;

  procedure proc_b is
    begin
     dbms_output.put_line('Inside procedure b');
     proc_c;
  end proc_b;

  procedure proc_a is
    begin
      dbms_output.put_line('Inside procedure a');
      proc_b;
  end proc_a;

  procedure force_err(in_status VARCHAR2) is
    begin
      dbms_output.put_line('ok ' || in_status);
  end;
end ORION_ERRORS_TEST;

---

-- Overloading:

CREATE OR REPLACE PACKAGE p
IS
   PROCEDURE l(bool IN BOOLEAN);

   /* Display a string */
   PROCEDURE l(stg IN VARCHAR2);

   /* Display a string and then a Boolean value */
   PROCEDURE l(
      stg    IN   VARCHAR2,
      bool   IN   BOOLEAN
   );
END;
-- ...

-- Call one of them
DECLARE
   v_is_valid BOOLEAN := book_info.is_valid_isbn('5-88888-66');
BEGIN
   p.l(v_is_valid);
END;


DECLARE
   PROCEDURE proc1(n IN PLS_INTEGER) IS
   BEGIN
      DBMS_OUTPUT.PUT_LINE('pls_integer version');
   END;

   PROCEDURE proc1(n IN NUMBER) IS
   BEGIN
      DBMS_OUTPUT.PUT_LINE('number version');
   END;
BEGIN
   proc1(1.1);
   proc1(1);
END;

---


CREATE OR REPLACE PACKAGE MKC_BUILD_MAINTENANCE AS
  PROCEDURE FIX_INDEXES(p_dropcreate IN NUMBER DEFAULT 0);
END MKC_BUILD_MAINTENANCE;
/
CREATE OR REPLACE PACKAGE BODY MKC_BUILD_MAINTENANCE AS
  /* CreatedBy: bheck
  ** Date:      02-Feb-21
  ** Purpose:   Maintain MKC Master Build
  ** Change:    02-Feb-21 - Defragment indexes when needed (ROION-49311)
  */
  PROCEDURE FIX_INDEXES(p_dropcreate IN NUMBER)  -- DEFAULT 0 is optional here!
  IS
    CURSOR indexCursor IS
      select distinct uic.INDEX_NAME
        from user_objects ut, user_tab_cols utc, user_ind_columns uic
       where ut.OBJECT_TYPE = 'TABLE'
         and ut.OBJECT_NAME = utc.TABLE_NAME
         and utc.COLUMN_NAME = 'AUDIT_SOURCE'
         and ut.OBJECT_NAME = uic.TABLE_NAME
         and ut.OBJECT_NAME not like '%_OLD'
         and ut.OBJECT_NAME = 'MKC_INVOICE_REVENUE'
and rownum<15
      ;

    v_ratio   NUMBER;
    v_height  NUMBER;
    v_blks    NUMBER;
    v_rows    NUMBER;
    v_fix     NUMBER := 0;
    v_cur     SYS_REFCURSOR;
    v_sql     VARCHAR2(1000);
    v_sql2    VARCHAR2(1000);
    v_keylist VARCHAR2(1000);
  BEGIN
    FOR indexRec IN indexCursor LOOP
      BEGIN
        DBMS_OUTPUT.put_line('Checking ' || indexRec.index_name || '...');
      
        EXECUTE IMMEDIATE 'analyze index ' || indexRec.index_name ||
                          ' validate structure';
                          --' validate structure ONLINE';  -- not performant
                          
        EXECUTE IMMEDIATE 'select decode(lf_rows, 0, 0, round((del_lf_rows/lf_rows)*100,2)) ratio, height, lf_blks, lf_rows from index_stats i'
          INTO v_ratio, v_height, v_blks, v_rows;
      
        IF (NVL(v_ratio, 0) > .2) THEN
          DBMS_OUTPUT.put_line('  Ratio of deleted rows to overall exceeds 20% threshold: ' || v_ratio);
          v_fix := v_fix + 1;
        ELSIF (v_height >= 4) THEN
          DBMS_OUTPUT.put_line('  Height is >= 4: ' || v_height);
          v_fix := v_fix + 1;
        ELSIF (v_rows < v_blks) THEN
          DBMS_OUTPUT.put_line('  Number of blocks exceeds number of rows: ' || v_blks || ' > ' || v_rows);
          v_fix := v_fix + 1;
        END IF;
        
        IF v_fix > 0 THEN
          v_sql := q'[ SELECT listagg(column_name, ',') within group (order by column_position) x from user_ind_columns WHERE index_name = ]'
                      || '''' || indexRec.index_name || '''';
          DBMS_OUTPUT.put_line(' ' || v_sql);

          OPEN v_cur FOR v_sql;
          LOOP
            FETCH v_cur INTO v_keylist;
            EXIT WHEN v_cur%NOTFOUND;

            IF p_dropcreate = 0 THEN
              DBMS_OUTPUT.put_line('  rebuilding index ' || indexRec.index_name);
              /*execute immediate 'alter index rebuld online' || indexRec.index_name;*/
            END IF;

            IF p_dropcreate = 1 THEN
              DBMS_OUTPUT.put_line('  dropping index ' || indexRec.index_name);
              /*execute immediate 'drop index ' || indexRec.index_name;*/

              v_sql2 := ' creating index ' || indexRec.index_name || ' on MKC_INVOICE_REVENUE (' || v_keylist || ')';
              DBMS_OUTPUT.put_line(' ' || v_sql2);
              /*execute immediate v_sql2;*/
            END IF;
          END LOOP;
        END IF;
      
        v_fix := 0;
        
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          DBMS_OUTPUT.put_line('  NO_DATA_FOUND for ' || indexRec.index_name || '...');
        WHEN OTHERS THEN
          IF SQLCODE = -01418 THEN
            DBMS_OUTPUT.put_line('  index does not exist for ' || indexRec.index_name || ' ...');
          ELSE
            DBMS_OUTPUT.put_line('  unexpected error processing ' || indexRec.index_name || ' ' || SQLCODE || ':' || SQLERRM || ': ' 
                                 || dbms_utility.FORMAT_ERROR_BACKTRACE);
          END IF;
      END;
    END LOOP;
  END FIX_INDEXES;
END MKC_BUILD_MAINTENANCE;
