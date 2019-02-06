
CREATE OR REPLACE TRIGGER DDL_LOGGING_TRIG
  AFTER DDL ON SCHEMA

DECLARE
  l_eventId NUMBER(10, 0);
  l_sqlText ORA_NAME_LIST_T;
  l_sqlTextVar CLOB := '';
  l_len NUMBER; 
  l_chunks NUMBER; 
  l_chunk VARCHAR2(32767);
  ix NUMBER := 1;

BEGIN
  SELECT uid_ddl_Event.NEXTVAL INTO l_eventId FROM SYS.DUAL;

  INSERT INTO ddl_event
    (ddl_event_Id,
     event_Date,
     Login_User,
     ora_Dict_Obj_Name,
     ora_Dict_Obj_Owner,
     ora_Dict_Obj_Type,
     ora_Sys_Event,
     machine,
     program,
     terminal,
     module,
     CLIENT_IDENTIFIER,
     osuser)
    (SELECT l_eventId,
            SYSDATE,
            ORA_LOGIN_USER,
            ORA_DICT_OBJ_NAME,
            ORA_DICT_OBJ_OWNER,
            ORA_DICT_OBJ_TYPE,
            ORA_SYSEVENT,
            s.machine,
            s.program,
            s.terminal,
            s.module,
            s.CLIENT_IDENTIFIER,
            s.osuser
       FROM SYS.DUAL, SYS.V_$SESSION s
      WHERE SYS_CONTEXT('USERENV', 'SESSIONID') = s.AUDSID(+));

  FOR i IN 1 .. ORA_SQL_TXT(l_sqlText) LOOP
    --Obscure passwords when altering User 
    IF ORA_DICT_OBJ_TYPE = 'USER' AND
       INSTR(UPPER(l_sqlText(i)), 'IDENTIFIED BY') != 0 THEN
      l_sqlText(i) := SUBSTR(l_sqlText(i),
                             1,
                             INSTR(UPPER(l_sqlText(i)), 'IDENTIFIED BY') + 13) || '*';
    END IF;
        
    l_sqlTextVar := trim(l_sqlTextVar || l_sqlText(i));
  END LOOP;
  
  -- Break large strings into max column width
  l_len := length(l_sqlTextVar);
  l_chunks := trunc(l_len / 4000) + 1;
    
  FOR i IN 1 .. l_chunks LOOP  
    l_chunk := substr(l_sqlTextVar, ix, 4000);

    ix := ix + 4000;
    
   INSERT INTO ddl_event_sql (event_Id, sql_Line, sql_Text)
    VALUES (l_eventId, i, l_chunk);
  END LOOP;

EXCEPTION
  WHEN OTHERS THEN                       
    dbms_output.put_line(SQLCODE || ':' || SQLERRM || ': ' || DBMS_UTILITY.format_error_backtrace);
    RAISE;
END;
/
