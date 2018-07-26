--https://www.red-gate.com/simple-talk/sql/oracle

CREATE OR REPLACE PROCEDURE friends_analysis AS
BEGIN
  FOR i IN (SELECT COUNT(*) cnt, gender
      FROM friend_name
      GROUP BY gender) LOOP

    IF i.gender = 'M' THEN
      dbms_output.put_line('I have '||i.cnt||' male friends.');
    ELSIF i.gender = 'F' THEN
      dbms_output.put_line('I have '||i.cnt||' female friends.');
    END IF;
  END LOOP;

  /* Assume the value in friend_name.friend_id represents the order in which we became friends. */
  FOR i IN (SELECT first_name, middle_name, last_name
      FROM friend_name
      WHERE friend_id = (SELECT MIN(friend_id)
                   FROM friend_name
                                    )
                  ) LOOP

    dbms_output.put_line('Our oldest friend is '||i.first_name||' '||i.middle_name||' '||i.last_name);
  END LOOP;

  FOR i IN (SELECT first_name, middle_name, last_name
      FROM friend_name
      WHERE friend_id = (SELECT MAX(friend_id)
           FROM friend_name
                                  )
                 ) LOOP

    dbms_output.put_line('Our newest friend is '||i.first_name||' '||i.middle_name||' '||i.last_name);
  END LOOP;
END friends_analysis;

-- call procedure
BEGIN
  friends_analysis;
END;



CREATE OR REPLACE PROCEDURE insert_new_friend (pFirst_name      VARCHAR2, 
                                               pLast_name       VARCHAR2, 
                                               pGender          VARCHAR2, 
                                               pPhone_country   NUMBER, 
                                               pPhone_area      NUMBER, 
                                               pPhone_number    NUMBER  ) AS
        -- declare our variables.
  v_friend_id NUMBER;
  v_phone_id  NUMBER;
BEGIN
  -- add a record to the friend_name table.
  INSERT INTO friend_name (friend_id, first_name, last_name, gender)
  VALUES (friend_id_seq.nextval, pFirst_name, pLast_name, pGender)
  RETURNING friend_id INTO v_friend_id;

  -- Next we need to add a new record to the PHONE_NUMBER table.
  INSERT INTO phone_number( phone_id, country_code, area_code, phone_number)
  VALUES (phone_id_seq.nextval, pPhone_country, pPhone_area, pPhone_number)
  RETURNING phone_id INTO v_phone_id;

  -- Finally, we need to associate our new friend with this phone number.
  INSERT INTO friend_phone (friend_id, phone_id, start_date)
  VALUES (v_friend_id, v_phone_id, SYSDATE);
END insert_new_friend;

-- call procedure
BEGIN
  insert_new_friend ('Jane', 'Simpson', 'F', 44,  207, 555551);
  insert_new_friend ('Ola',  'Sanusi',  'M', 234, 1,   890555);
END;



CREATE OR REPLACE FUNCTION get_friend_phone_number (pFirst_name  VARCHAR2,
                                                    pLast_name   VARCHAR2)  RETURN NUMBER AS
  V_phone_no  NUMBER;
BEGIN
        FOR i IN (SELECT pn.phone_number
                  FROM phone_number pn, friend_name fn, friend_phone fp
                  WHERE UPPER(fn.first_name) = UPPER(pFirst_name)
                  AND UPPER(fn.last_name) = UPPER(pLast_name)
                  AND fn.friend_id = fp.friend_id
                  AND fp.start_date <= SYSDATE AND NVL(fp.end_date, SYSDATE + 1) > SYSDATE
                  AND fp.phone_id = pn.phone_id) LOOP

                  v_phone_no := i.phone_number;
        END LOOP;

        -- All functions MUST return something (even if it is a null).
        RETURN v_phone_no;
END get_friend_phone_number;

-- call function
DECLARE
  v_joey_phone    NUMBER;

BEGIN
  -- Assign our function to a variable.
  v_joey_phone    := get_friend_phone_number('Joey','Tribiani');
  dbms_output.put_line('Joey''s phone number is '||v_joey_phone);

  -- Use our function in a select statement
  FOR i IN (SELECT first_name, last_name, get_friend_phone_number(first_name, last_name) telno
      FROM friend_name) LOOP

    dbms_output.put_line(i.first_name||': '||i.telno);
  END LOOP;
END;
