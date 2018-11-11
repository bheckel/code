CREATE OR REPLACE PACKAGE orion32702 IS

  TYPE a_ids IS VARRAY(3) OF NUMBER;
  
  PROCEDURE orion32702_test(runprod NUMBER, ignoreauditflag NUMBER, unit NUMBER, period VARCHAR2, ids a_ids);

  PROCEDURE main;

/*TODO set these up as arrays to allow running >1 id at a time */
  updated1 DATE;
  updated0 DATE;
  updatedby1 NUMBER;
  updatedby0 NUMBER;
  srch_match_code1 VARCHAR2(80);
  srch_match_code0 VARCHAR2(80);
  rc VARCHAR2(7);
  
END orion32702;
/
CREATE OR REPLACE PACKAGE BODY orion32702 IS

  PROCEDURE orion32702_test(runprod NUMBER, ignoreauditflag NUMBER, unit NUMBER, period VARCHAR2, ids a_ids) is

    BEGIN

       /********************************* Unit Test 1 **********************************************/ 
      IF unit = 1 THEN 
        dbms_output.put_line('unit:' || unit || ' runprod: ' || runprod || ' ign:' || ignoreauditflag || '  .....srch_id does exist:');
        
        FOR i IN 1 .. ids.COUNT LOOP
          rc := 'UNKNOWN';
          updated0 := NULL;

          IF period = 'BEFORE' THEN
            FOR rec IN (select * FROM reference_srch WHERE reference_srch_id = ids(i)) LOOP
              dbms_output.put_line('BEFORE srch_id: ' || rpad(rec.reference_srch_id,10,' ') || ' up: ' || rec.updated || ' upb: ' || rpad(rec.updatedby,8,' ') || ' smc: ' || rec.srch_MATCH_CODE || ' bada: ' || rec.badabingle || ' cr: ' || rec.created || ' crb: ' || rec.createdby);
            END LOOP;
          END IF;
          
          IF runprod = 1 THEN
            set_reference_match_code(inreference_id => ids(i), ignore_audit => ignoreauditflag);
          ELSE
            z_set_reference_match_code(inreference_id => ids(i), ignore_audit => ignoreauditflag);
          END IF;
          
          IF period = 'AFTER' THEN
            FOR rec IN (select * FROM reference_srch WHERE reference_srch_id = ids(i)) LOOP
              IF runprod = 1 THEN
                updated1           := rec.updated;
                updatedby1         := rec.updatedby;
                srch_match_code1 := rec.srch_match_code;
              ELSE
                updated0           := rec.updated;
                updatedby0         := rec.updatedby;
                srch_match_code0 := rec.srch_match_code;
              END IF;
              IF runprod = 0 THEN
                IF ( (updated1 = updated0) OR ((updated1 IS NULL) AND (updated0 IS NULL)) ) AND
                   ( (updatedby1 = updatedby0) OR ((updatedby1 IS NULL) AND (updatedby0 IS NULL)) ) AND
                   ( (srch_match_code1 = srch_match_code0) OR ((srch_match_code1 IS NULL) AND (srch_match_code0 IS NULL)) ) THEN
                  rc := 'PASS   ';
                ELSE
                  rc := 'FAIL!!!';
                END IF;
              END IF;
              dbms_output.put_line(rc || ' AFTER: ' || rpad(rec.reference_srch_id,10,' ') || ' up: ' || rec.updated || ' upb: ' || rpad(rec.updatedby,8,' ') || ' smc: ' || rec.srch_MATCH_CODE || ' bada: ' || rec.badabingle || ' cr: ' || rec.created || ' crb: ' || rec.createdby);
            END LOOP;
          END IF;
          
        END LOOP;

        ROLLBACK;
      END IF;
      
      /******************************** Unit Test 2 ***********************************************/                             
      IF unit = 2 THEN
        dbms_output.put_line('unit:' || unit || ' runprod:' || runprod || ' ign:' || ignoreauditflag || '  .....pretend srch_id does NOT exist:');
        
        FOR i IN 1 .. ids.COUNT LOOP
          DELETE FROM reference_srch WHERE reference_srch_id = ids(i);

          rc := 'UNKNOWN';
          updated0 := NULL;
          
          IF runprod = 1 THEN
            set_reference_match_code(inreference_id => ids(i), ignore_audit => ignoreauditflag);
          ELSE
            z_set_reference_match_code(inreference_id => ids(i), ignore_audit => ignoreauditflag);
          END IF;
          
          FOR rec IN (select * FROM reference_srch WHERE reference_srch_id = ids(i)) LOOP
            IF runprod = 1 THEN
              updated1           := rec.updated;
              updatedby1         := rec.updatedby;
              srch_match_code1 := rec.srch_match_code;
            ELSE
              updated0           := rec.updated;
              updatedby0         := rec.updatedby;
              srch_match_code0 := rec.srch_match_code;
            END IF;

            IF runprod = 0 THEN
              IF ( (updated1 = updated0) OR ((updated1 IS NULL) AND (updated0 IS NULL)) ) AND
                 ( (updatedby1 = updatedby0) OR ((updatedby1 IS NULL) AND (updatedby0 IS NULL)) ) AND
                 ( (srch_match_code1 = srch_match_code0) OR ((srch_match_code1 IS NULL) AND (srch_match_code0 IS NULL)) ) THEN
                rc := 'PASS   ';
              ELSE
                rc := 'FAIL!!!';
              END IF;
            END IF;

            dbms_output.put_line(rc || ' AFTER: ' || rpad(rec.reference_srch_id,10,' ') || ' up: ' || rec.updated || ' upb: ' || rpad(rec.updatedby,8,' ') || ' smc: ' || rec.srch_MATCH_CODE || ' bada: ' || rec.badabingle || ' cr: ' || rec.created || ' crb: ' || rec.createdby);
          END LOOP;
          
        END LOOP;
        
        ROLLBACK;
      END IF;

  END orion32702_test;

    
  PROCEDURE main IS  
    
    ids a_ids := a_ids();
    cnt INTEGER := 0;
    
    CURSOR c_rand IS
      /* Oracle will only truly randomize if '*' is used */
      SELECT * 
      FROM reference_srch SAMPLE(0.1) 
      --TODO
      WHERE ROWNUM<2;
      
  BEGIN
            
    FOR i IN c_rand LOOP 
       cnt := cnt + 1;
        
       ids.EXTEND; 
       ids(cnt) := i.reference_srch_id; 
    END LOOP; 

    dbms_output.put_line(to_char(sysdate, 'DDMON HH:MM') || ' ---------------------------');
    orion32702_test(runprod => 1, ignoreauditflag => 1, unit => 1, period => 'BEFORE', ids => ids);
    orion32702_test(runprod => 0, ignoreauditflag => 1, unit => 1, period => 'BEFORE', ids => ids);
    dbms_output.put_line(chr(10)); 
    orion32702_test(runprod => 1, ignoreauditflag => 1, unit => 1, period => 'AFTER', ids => ids);
    orion32702_test(runprod => 0, ignoreauditflag => 1, unit => 1, period => 'AFTER', ids => ids);
    
    dbms_output.put_line('---------------------------');
    orion32702_test(runprod => 1, ignoreauditflag => 0, unit => 1, period => 'BEFORE', ids => ids);
    orion32702_test(runprod => 0, ignoreauditflag => 0, unit => 1, period => 'BEFORE', ids => ids);
    dbms_output.put_line(chr(10)); 
    orion32702_test(runprod => 1, ignoreauditflag => 0, unit => 1, period => 'AFTER', ids => ids);
    orion32702_test(runprod => 0, ignoreauditflag => 0, unit => 1, period => 'AFTER', ids => ids);
    
    dbms_output.put_line('---------------------------');

   dbms_output.put_line(chr(10) || 'xxxxxxxxxx ignore is ignored inserting a new srch record xxxxxxxxxxxxxxxxx');

    dbms_output.put_line('---------------------------');
    orion32702_test(runprod => 1, ignoreauditflag => 1, unit => 2, period => 'AFTER', ids => ids);
    orion32702_test(runprod => 0, ignoreauditflag => 1, unit => 2, period => 'AFTER', ids => ids);
    
    dbms_output.put_line('---------------------------');

    orion32702_test(runprod => 1, ignoreauditflag => 0, unit => 2, period => 'AFTER', ids => ids);
    orion32702_test(runprod => 0, ignoreauditflag => 0, unit => 2, period => 'AFTER', ids => ids);

    dbms_output.put_line('---------------------------'); 
  END main;
  
END orion32702;
/
