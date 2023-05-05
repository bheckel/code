-- Created: 04-May-2023 (Bob Heckel)

SELECT * FROM  DBA_ROLE_PRIVS WHERE grantee in('ES_ATLAS','SETARS','ES_ATLASBUILD') and granted_role='CTXAPP' ORDER BY 1;

--  set serveroutput on size 500000
create or replace package atlas_ctx_pkg
as
  procedure setx;
end;
/
create or replace package body atlas_ctx_pkg
as
  procedure setx is
    eml  varchar2(99);
    begin
      select email into eml from employee@roion_prod_ro where userid = SYS_CONTEXT('userenv', 'os_user');
      DBMS_OUTPUT.put_line('sysdate: ' || eml);
      dbms_session.set_context('atlas_context', 'employee_email', eml);
    end;
end;

exec atlas_ctx_pkg.setx;

CREATE or replace CONTEXT atlas_context USING atlas_ctx_pkg;
SELECT SYS_CONTEXT('atlas_context', 'employee_email') FROM DUAL;  --Bob.Heckel@as.com

