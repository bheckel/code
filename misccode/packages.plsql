CREATE OR REPLACE PACKAGE ztestbob AS
  
  PROCEDURE delay_buffer_test;

END ztestbob;
/
CREATE OR REPLACE PACKAGE BODY ztestbob AS

  PROCEDURE delay_buffer_test
  IS
    l_now DATE;

  BEGIN
    dbms_output.put_line('ok1');
    SELECT sysdate INTO l_now FROM DUAL; LOOP EXIT WHEN l_now +(10 * (1 / 86400)) = sysdate; END LOOP;
    dbms_output.put_line('ok2');
  END;

END ztestbob;


---


CREATE OR REPLACE PACKAGE manage_students AS

  PROCEDURE find_sname(i_student_id IN student.student_id%TYPE,
                       o_first_name OUT student.first_name%TYPE,
                       o_last_name OUT student.last_name%TYPE);

  FUNCTION id_is_good(i_student_id IN student.student_id%TYPE) RETURN BOOLEAN;

END manage_students;


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
