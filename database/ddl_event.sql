CREATE SEQUENCE  setars.UID_DDL_EVENT  MINVALUE 1 MAXVALUE 999999999999999999999999999 INCREMENT BY 10 START WITH 10 CACHE 10 NOORDER  NOCYCLE  NOKEEP  NOSCALE  GLOBAL ;

  CREATE TABLE setars.DDL_EVENT 
   (	DDL_EVENT_ID NUMBER(10,0), 
	EVENT_DATE DATE, 
	LOGIN_USER VARCHAR2(30), 
	ORA_DICT_OBJ_NAME VARCHAR2(50), 
	ORA_DICT_OBJ_OWNER VARCHAR2(30), 
	ORA_DICT_OBJ_TYPE VARCHAR2(30), 
	ORA_SYS_EVENT VARCHAR2(30), 
	MACHINE VARCHAR2(64), 
	PROGRAM VARCHAR2(64), 
	TERMINAL VARCHAR2(30), 
	MODULE VARCHAR2(64), 
	CLIENT_IDENTIFIER VARCHAR2(64), 
	OSUSER VARCHAR2(30)
   );
   CREATE INDEX setars.DDL_EVENT_ID_IX ON setars.DDL_EVENT (DDL_EVENT_ID);
   
CREATE TABLE setars.DDL_EVENT_SQL 
   (	EVENT_ID NUMBER(10,0), 
	SQL_LINE NUMBER(10,0), 
	SQL_TEXT VARCHAR2(4000) COLLATE USING_NLS_COMP, 
	SQL_TEXT_ALL CLOB COLLATE USING_NLS_COMP
   )  DEFAULT COLLATION USING_NLS_COMP SEGMENT CREATION IMMEDIATE 
  PCTFREE 10 PCTUSED 40 INITRANS 1 MAXTRANS 255 
 ROW STORE COMPRESS ADVANCED LOGGING
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1
  BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
  TABLESPACE ES_01 
 LOB (SQL_TEXT_ALL) STORE AS BASICFILE (
  TABLESPACE ES_01 ENABLE STORAGE IN ROW CHUNK 8192 RETENTION 
  NOCACHE LOGGING 
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1
  BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)) ;
CREATE INDEX setars.DDL_EVENT_SQL_ID_IX ON setars.DDL_EVENT_SQL (EVENT_ID) ;


CREATE OR REPLACE TRIGGER DDL_LOGGING_TRIG
  AFTER DDL ON SCHEMA
DECLARE
  l_eventId NUMBER(10, 0);
  l_sqlText ORA_NAME_LIST_T;
  l_sqlTextVar CLOB := '';
  l_sqlTextVarPreview VARCHAR(63);  -- older versions of this code stored 63 chars per line

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

    -- Provide a preview column to avoid hiding everything in the CLOB.  Also useful for queries
    -- across database links where CLOBS aren't SELECTable.
    l_sqlTextVarPreview := substr(l_sqlTextVar, 1, 60) || '...';
  END LOOP;

  IF (upper(l_sqlTextVar) NOT LIKE '%DDL_EVENT_SQL%') THEN
    INSERT INTO ddl_event_sql
          (event_Id, sql_text, sql_text_all)
    VALUES
          (l_eventId, l_sqlTextVarPreview, l_sqlTextVar);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    NULL;
END;
