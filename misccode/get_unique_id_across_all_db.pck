---DECLARE
---  dbg boolean := sys.diutil.int_to_bool(1);
---  ids maint_types.numbertable;  -- if free number(s) also need to be returned in a collection
---BEGIN maint.get_unique_id_across_all_db(seq_name => 'uid_orion_37551',  -- test table orion_37751 on ESD, EST, ESPS
---                                        num_seqs_requested => 2,
---                                        ids => ids,
---                                        dbg => dbg);
---END;

CREATE OR REPLACE PACKAGE ORION37551 IS
  -- ----------------------------------------------------------------------------
  -- Author: Bob Heckel (boheck)
  -- Date:   
  -- Usage:  
  -- JIRA:   ORION-
  -- ----------------------------------------------------------------------------

     TYPE numberTable IS TABLE OF NUMBER; --exists in maint_types

         
 PROCEDURE do;
  PROCEDURE do2;
 PROCEDURE OLDget_unique_crossdb_sequence(seq_name IN VARCHAR2, num_seqs_requested IN PLS_INTEGER);
/* PROCEDURE do2;*/
 PROCEDURE get_unique_id_across_all_db(seq_name IN VARCHAR2, num_seqs_requested IN PLS_INTEGER DEFAULT 1, ids OUT numberTable, dbg BOOLEAN DEFAULT FALSE);
END;
/
CREATE OR REPLACE PACKAGE BODY ORION37551 IS

  PROCEDURE do2 IS
        sqlstr              VARCHAR2(1000);
        seq_name VARCHAR2(1000):='uid_email_messages';
            l_nextfree_num      NUMBER := 19280;
                l_current_num       NUMBER;
    BEGIN
              sqlstr := 'BEGIN Maint.reset_unique_sequence@ESD(:1, :2); END;';
          EXECUTE IMMEDIATE sqlstr
                      INTO l_current_num
            USING IN seq_name,  l_nextfree_num;


          dbms_output.put_line( ' new sequence number has been reset to ' || l_current_num);  
  END;

  PROCEDURE do IS

 -- PROCEDURE reset_unique_sequence(p_sequence       VARCHAR2,
   --                               newCurrentNumber IN NUMBER DEFAULT null) is
   

    v_current_num NUMBER;
    v_new_num     NUMBER;
    v_unique_num  NUMBER;
    
    p_sequence       VARCHAR2(99) := 'uid_email_messages';
    newCurrentNumber NUMBER := NULL;

  BEGIN
/*    if SYS_CONTEXT('USERENV', 'DB_NAME') = 'ESP' then

      v_unique_num := 0;


    elsif SYS_CONTEXT('USERENV', 'DB_NAME') = 'ESD' then

      v_unique_num := 1;

    elsif SYS_CONTEXT('USERENV', 'DB_NAME') = 'EST' then

      v_unique_num := 2;

    elsif SYS_CONTEXT('USERENV', 'DB_NAME') = 'ESPS' then

      v_unique_num := 3;

    elsif SYS_CONTEXT('USERENV', 'DB_NAME') = 'ESUAT' then

      v_unique_num := 4;

    elsif SYS_CONTEXT('USERENV', 'DB_NAME') = 'ESTS' then

      v_unique_num := 5;

    elsif SYS_CONTEXT('USERENV', 'DB_NAME') = 'ESR' then

      v_unique_num := 9;

    else*/
      v_unique_num := 10; --10;
/*
    end if;*/

    --get the current value for sequence
/*    EXECUTE IMMEDIATE 'SELECT ' || p_sequence || '.NEXTVAL FROM dual'
      INTO v_current_num;*/
v_current_num := 17561;

    -- If new number provided
/*    if ((newCurrentNumber is not null) AND
       (newCurrentNumber != v_current_num)) Then
      -- set INCREMENT BY to change the next number retreived
      EXECUTE IMMEDIATE 'ALTER SEQUENCE ' || p_sequence || ' INCREMENT BY ' ||
                        (newCurrentNumber - v_current_num) || ' MINVALUE 1';*/
      
                        
      -- increment the sequence
/*      EXECUTE IMMEDIATE 'SELECT ' || p_sequence || '.NEXTVAL FROM dual'
        INTO v_current_num;
    end if;*/

    --set round the current value to nearest 10 add 10 and the unique number
/*    EXECUTE IMMEDIATE 'SELECT (round(' || v_current_num || ', -1) + 10 + ' ||
                      v_unique_num || ') -  ' || v_current_num ||
                      ' FROM dual'
      INTO v_new_num;*/
v_new_num := round(v_current_num, -1) + 10 + v_unique_num -  v_current_num;

    -- set the increment by to the difference between old an new value
/*    EXECUTE IMMEDIATE 'ALTER SEQUENCE ' || p_sequence || ' INCREMENT BY ' ||
                      v_new_num;

    -- increment the sequence
    EXECUTE IMMEDIATE 'SELECT ' || p_sequence || '.NEXTVAL FROM dual'
      INTO v_current_num;

    -- set the increment by back to 10
    EXECUTE IMMEDIATE 'ALTER SEQUENCE ' || p_sequence || ' INCREMENT BY ' || 10;

    dbms_output.put_line(v_current_num ||
                         ' RESET_UNIQUE_SEQUENCE updated for ' ||
                         p_sequence);*/
                         
  dbms_output.put_line(v_new_num);
      
  END;


  PROCEDURE OLDget_unique_crossdb_sequence(seq_name IN VARCHAR2, num_seqs_requested IN PLS_INTEGER) IS
    TYPE db_t IS TABLE OF VARCHAR2(5) INDEX BY PLS_INTEGER;
    dbs db_t;
    
    l_current_num       NUMBER := 0;
    l_current_esp_num   NUMBER := 0;
    l_current_esd_num   NUMBER := 0;
    l_current_est_num   NUMBER := 0;
    l_current_esps_num  NUMBER := 0;    
    l_current_esuat_num NUMBER := 0;
    l_current_ests_num  NUMBER := 0;
--    l_current_esr_num   NUMBER := 0; TODO privilege problems
    l_max_num           NUMBER := 0;
    l_nextfree_num      NUMBER := 0;
    l_advance_by        NUMBER;
    ix                  PLS_INTEGER;
        
    BEGIN
      -- Indexed by their v_unique_num in Maint.reset_unique_sequence
      dbs(0) := 'ESP';
      dbs(1) := 'ESD';
      dbs(2) := 'EST';
      dbs(3) := 'ESPS';
      /*dbs(4) := 'ESUAT';
      dbs(5) := 'ESTS';*/
--      dbs(9) := 'ESR';
            
      ix := dbs.FIRST;
       
      WHILE ( ix IS NOT NULL) LOOP
        -- Get current sequence number from each database
        EXECUTE IMMEDIATE 'SELECT ' || seq_name || '.NEXTVAL@' || dbs(ix) || ' FROM dual'
                     INTO l_current_num;
        
        EXECUTE IMMEDIATE 'COMMIT';  -- close remote link "transaction"
  
-- TODO, won't work, need links again later
--        IF SYS_CONTEXT('USERENV', 'DB_NAME') != dbs(ix) THEN
          -- Work around parameter open_link = 4
--          EXECUTE IMMEDIATE 'ALTER SESSION CLOSE DATABASE LINK ' || dbs(ix);
--        END IF;

      IF dbs(ix) = 'ESP' THEN
          l_current_esp_num := l_current_num;
        ELSIF dbs(ix) = 'ESD' THEN
          l_current_esd_num := l_current_num;
        ELSIF dbs(ix) = 'EST' THEN
          l_current_est_num := l_current_num;
        ELSIF dbs(ix) = 'ESPS' THEN
          l_current_esps_num := l_current_num;  
        ELSIF dbs(ix) = 'ESUAT' THEN
          l_current_esuat_num := l_current_num;
        ELSIF dbs(ix) = 'ESTS' THEN
          l_current_ests_num := l_current_num;
--        ELSIF dbs(ix) = 'ESR' THEN
--          l_current_esps_num := l_current_num;
        END IF;

        IF l_current_num > l_max_num THEN
          l_max_num := l_current_num;
        END IF;
          
        ix := dbs.NEXT(ix);
      END LOOP;
        
      dbms_output.put_line('BEFORE: l_current_esp_num is '   || l_current_esp_num  || 
                                 ': l_current_esd_num is '   || l_current_esd_num  || 
                                 ': l_current_est_num is '   || l_current_est_num  || 
                                 ': l_current_esps_num is '  || l_current_esps_num ||
                                 ': l_current_esuat_num is ' || l_current_esuat_num ||
                                 ': l_current_ests_num is '  || l_current_ests_num ||
--                                 ': l_current_esr_num is '   || l_current_esr_num ||
                                 ': l_max_num is '           || l_max_num);
        
      IF l_max_num > l_current_esp_num THEN
        -- Increase ESP's NEXTVAL (which increments by 10) to the next highest number above the current database-wide max
        l_nextfree_num := (l_max_num - l_current_esp_num) + l_current_esp_num + 10;
      ELSE
        -- ESP is the highest so just go to its next free sequence number
        l_nextfree_num := l_current_esp_num + 10;      
      END IF;
       
      dbms_output.put_line('MAX: ' || l_max_num || ' NEXTFREE: ' || l_nextfree_num);
        
      -- Return next available number(s) to user
      FOR i IN 1 .. num_seqs_requested LOOP
        l_nextfree_num := l_nextfree_num + 1;
        dbms_output.put_line('Free sequence number ' || i || ': ' || l_nextfree_num);
      END LOOP;

      -- Push all sequences above the newly returned current numbers.
      -- Can't run procedure across db links: Maint.reset_unique_sequence(seq_name, l_nextfree_num);
      ix := dbs.FIRST;
      
      WHILE ( ix IS NOT NULL) LOOP
        l_advance_by := 0;

        IF dbs(ix) = 'ESP' THEN
          l_advance_by := l_nextfree_num - l_current_esp_num;        
        ELSIF dbs(ix) = 'ESD' THEN
          l_advance_by := l_nextfree_num - l_current_esd_num;
        ELSIF dbs(ix) = 'EST' THEN
          l_advance_by := l_nextfree_num - l_current_est_num;
        ELSIF dbs(ix) = 'ESPS' THEN
          l_advance_by := l_nextfree_num - l_current_esps_num;
        /*ELSIF dbs(ix) = 'ESUAT' THEN
          l_advance_by := l_nextfree_num - l_current_esuat_num;
        ELSIF dbs(ix) = 'ESTS' THEN
          l_advance_by := l_nextfree_num - l_current_ests_num;*/
--        ELSIF dbs(ix) = 'ESR' THEN
--          l_advance_by := l_nextfree_num - l_current_esr_num;
        END IF;    

        IF l_advance_by > 0 THEN
          -- Sequences increment by 10, plus 1 extra loop in case another process is simultaneously claiming a sequence number
          l_advance_by := round(l_advance_by / 10) + 1;
                  
          -- Can't run ALTER SEQUENCE across dbs so advance by looping in implicit groups of 10
          FOR i IN 1 .. l_advance_by LOOP
--DEBUG
--          EXECUTE IMMEDIATE 'SELECT ' || seq_name || '.NEXTVAL@' || dbs(ix) || ' FROM dual'
            EXECUTE IMMEDIATE 'SELECT 1 x FROM dual'
                         INTO l_current_num;
                         
            EXECUTE IMMEDIATE 'COMMIT';  -- close remote link "transaction"
          END LOOP;

--DEBUG prove new seq
dbms_output.put_line(l_advance_by);          
          dbms_output.put_line('NEW ' || dbs(ix) || ': l_current_num is ' || l_current_num);

          ix := dbs.NEXT(ix);
        END IF;
      END LOOP;
  END OLDget_unique_crossdb_sequence; 
  
    -- ----------------------------------------------------------------------------
  -- Name:    get_unique_ids_across_all_db
  -- Author:  Bob Heckel (boheck)   
  -- Date:    14May19
  -- Purpose: Return the next highest available unique sequence number(s) across
  --          all databases then reset the sequence on each database above that
  --          maximum. Using a procedure instead of a function to avoid trouble 
  --          with the DDL statements.
  -- ----------------------------------------------------------------------------
  PROCEDURE get_unique_id_across_all_db(seq_name IN VARCHAR2, num_seqs_requested IN PLS_INTEGER DEFAULT 1, ids OUT numberTable, dbg BOOLEAN DEFAULT FALSE) IS
    TYPE db_t IS TABLE OF VARCHAR2(5) INDEX BY PLS_INTEGER;
    dbs db_t;
    
    l_current_num       NUMBER := 0;
    l_current_esp_num   NUMBER := 0;
    l_current_esd_num   NUMBER := 0;
    l_current_est_num   NUMBER := 0;
    l_current_esps_num  NUMBER := 0;    
    l_current_esuat_num NUMBER := 0;
    l_max_num           NUMBER := 0;
    l_nextfree_num      NUMBER := 0;
    l_sqlstr            VARCHAR2(1000);
    ix                  PLS_INTEGER;
    
    BEGIN
      -- Indexed by their v_unique_num in Maint.reset_unique_sequence
      --dbs(0) := 'ESP';
      dbs(1) := 'ESD';
      dbs(2) := 'EST';
      dbs(3) := 'ESPS';
      --dbs(4) := 'ESUAT';
            
      ix := dbs.FIRST;
      -- Get current sequence number from each database
      WHILE ( ix IS NOT NULL) LOOP
        l_sqlstr := 'BEGIN Maint.get_next_seqnum@' || dbs(ix) || '(:1, :2); END;';
        
        EXECUTE IMMEDIATE l_sqlstr
          USING IN seq_name, IN OUT l_current_num;

        IF dbs(ix) = 'ESP' THEN
          l_current_esp_num := l_current_num;
        ELSIF dbs(ix) = 'ESD' THEN
          l_current_esd_num := l_current_num;
        ELSIF dbs(ix) = 'EST' THEN
          l_current_est_num := l_current_num;
        ELSIF dbs(ix) = 'ESPS' THEN
          l_current_esps_num := l_current_num;  
        ELSIF dbs(ix) = 'ESUAT' THEN
          l_current_esuat_num := l_current_num;
        END IF;

        IF l_current_num >= l_max_num THEN
          l_max_num := l_current_num;
        END IF;
          
        ix := dbs.NEXT(ix);
      END LOOP;

      IF dbg THEN
        dbms_output.put_line('BEFORE: l_current_esp_num is '   || l_current_esp_num  || 
                                   ': l_current_esd_num is '   || l_current_esd_num  || 
                                   ': l_current_est_num is '   || l_current_est_num  || 
                                   ': l_current_esps_num is '  || l_current_esps_num ||
                                   ': l_current_esuat_num is ' || l_current_esuat_num ||
                                   ': l_max_num is '           || l_max_num);
      END IF;
        
      IF l_max_num > l_current_esp_num THEN
        -- ESP is not the highest so increase ESP's NEXTVAL (default increments by 10) to the next highest 
        -- number above the current database-wide max
        l_nextfree_num := (l_max_num - l_current_esp_num) + l_current_esp_num + 10;
      ELSE
        -- ESP is the highest so just go to its next free sequence number
        l_nextfree_num := l_current_esp_num + 10;      
      END IF;
      
      IF dbg THEN 
        dbms_output.put_line('Current max of all databases is ' || l_max_num || ' so next available is ' || l_nextfree_num);
      END IF;
      
      ids := numberTable();
      ids.extend(num_seqs_requested);
      -- Return next available number(s) to user...
      FOR i IN 1 .. num_seqs_requested LOOP
        l_nextfree_num := l_nextfree_num + 1;
        dbms_output.put_line('Free sequence number ' || i || ' of ' || num_seqs_requested || ': ' || l_nextfree_num);
        ids(i) := l_nextfree_num;
      END LOOP;

      -- ...then push all db sequences above the newly returned current number(s)
      l_nextfree_num := l_nextfree_num + 1;
      
      ix := dbs.FIRST;
      WHILE ( ix IS NOT NULL) LOOP
        IF l_nextfree_num > 0 THEN
          IF dbg THEN
            dbms_output.put_line(dbs(ix) || ' new sequence number will be reset to (or above) ' || l_nextfree_num);
          END IF;
          
          l_sqlstr := 'BEGIN Maint.reset_unique_sequence@' || dbs(ix) || '(:1, :2); END;';
          
          EXECUTE IMMEDIATE l_sqlstr
            USING IN seq_name, IN OUT l_nextfree_num;
        
          ix := dbs.NEXT(ix);
        END IF;
      END LOOP;
  END get_unique_id_across_all_db;
END;

  
/
