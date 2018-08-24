CREATE OR REPLACE PACKAGE testpkg AS

  PROCEDURE find_sname(i_student_id IN student.student_id%TYPE,
                       o_first_name OUT student.first_name%TYPE,
                       o_last_name OUT student.last_name%TYPE);

  FUNCTION id_is_good(i_student_id IN student.student_id%TYPE) RETURN BOOLEAN;

END testpkg;


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
