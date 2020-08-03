-- Created: Tue 13 Aug 2019 10:54:45 (Bob Heckel) 

  PROCEDURE do_update(col VARCHAR2) IS
    TYPE chartbl IS TABLE OF VARCHAR(128) INDEX BY VARCHAR2(128);
    
    names charTbl;
    mindt      DATE;
    i          NUMBER := 0;
    key        VARCHAR(50);
    cnt        NUMBER;
    t1 integer;
        t2 integer; 

    CURSOR c1 IS
      SELECT table_name, low_value
        FROM rion39366_c@sed
     ;

    BEGIN
       FOR c1rec IN c1 LOOP
         dbms_stats.convert_raw_value(hextoraw(c1rec.LOW_VALUE), mindt);
      
         IF mindt < '01JAN1970' THEN
            -- This tbl has bad records, add it to the table collection:
            i := i + 1;

           names(c1rec.table_name) := to_char(mindt, 'DD-MON-YYYY');
         END IF;
       END LOOP;
         
       key := names.FIRST;
         
       WHILE key IS NOT NULL LOOP
         t1 := dbms_utility.get_time();
         EXECUTE IMMEDIATE 'UPDATE ' || key ||
                             ' SET ' || col || ' = ''01JAN1970''
                             WHERE ' || col || ' < ''01JAN1970'''
         ;
      
         cnt := SQL%ROWCOUNT;
        
        t2 := (dbms_utility.get_time()-t1)/100;
         dbms_output.put_line(key || ' ' || names(key) || ' ' || cnt || ' ' || t2);
         --COMMIT;
         rollback;
         
         key := names.NEXT(key);
       END LOOP;
       
       EXCEPTION
         WHEN OTHERS THEN
           dbms_output.put_line(SQLCODE || ': ' || SQLERRM || ': ' || DBMS_UTILITY.format_error_backtrace);
           ROLLBACK;
  END do_update;
END;

---

declare
  curr_time1   timestamp with time zone := systimestamp;
  curr_time2   number := dbms_utility.get_time;
begin

  loop
    exit when current_timestamp >= curr_time1 + interval '5' second;
  end loop;

  dbms_output.put_line( 'Elapsed Time = ' || ( dbms_utility.get_time - curr_time2 ) / 100 );

end;
/
--Elapsed Time = 5

---

DECLARE

  rc BOOLEAN;
  t1 timestamp;
  t2 timestamp;

BEGIN 

  SELECT SYSTIMESTAMP INTO t1 FROM DUAL;
  
  rc := SUP_HAS_ACTIVE_SITES(2124);
--  rc := SUP_HAS_ACTIVE_SITES(930);
  
  IF rc THEN
    dbms_output.put_line('y');
  ELSE
    dbms_output.put_line('n');
  END IF;
  
  SELECT SYSTIMESTAMP INTO t2 FROM DUAL;
  
  dbms_output.put_line(t2 - t1);
END;
