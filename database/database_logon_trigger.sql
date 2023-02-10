drop table SETARS_LOGINS;
 create table SETARS_LOGINS (
    osuser varchar2(30),
    machine varchar2(30),
    program varchar2(30),
    ip varchar2(30)
  );

CREATE OR REPLACE TRIGGER LOG_SETARS_LOGINS
AFTER LOGON ON DATABASE
  DECLARE
    osUser VARCHAR2(30);
    machine VARCHAR2(100);
    prog VARCHAR2(100);
    ip_user VARCHAR2(15);
  BEGIN
    SELECT OSUSER, MACHINE, PROGRAM, ora_client_ip_address
      INTO osUser, machine, prog, ip_user
      FROM v$session
     WHERE SID = SYS_CONTEXT('USERENV', 'SID');

  INSERT into SETARS_LOGINS values ( osUser, machine, prog, ip_user) ; commit;

--    IF (osUser = 'APuente' AND prog = 'SQL Developer')THEN
--        RAISE_APPLICATION_ERROR(-20000,'Denied!  You are not allowed to logon from host '||prog|| ' using '|| osUser);
--    END IF;
END;

select * from t;
drop trigger LOG_SETARS_LOGINS;
