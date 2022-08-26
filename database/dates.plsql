-- Created: 24-Aug-2022 (Bob Heckel)
--  set serveroutput on size 100000
declare
  dt date := sysdate;
  dtt timestamp := sysdate;
  cnt number;
begin
  EXECUTE IMMEDIATE 'ALTER SESSION set NLS_DATE_FORMAT = ''DD-MON-RR''';
  
  update zbob set actual_updated=sysdate-interval '12' hour where rownum < 5; commit;
  
  DBMS_OUTPUT.put_line('now ' || dt);
  DBMS_OUTPUT.put_line('now ' || dtt);

  dt := sysdate - interval '13' hour;
  DBMS_OUTPUT.put_line('yesterday ' || dt);
  dtt := sysdate - interval '13' hour;
  DBMS_OUTPUT.put_line('yesterday ' || dtt);
  
  execute immediate 'select count(1) from zbob where actual_updated > :1' into cnt using dt;
  DBMS_OUTPUT.put_line(cnt);
  
  execute immediate 'select count(1) from zbob where actual_updated > :1' into cnt using dtt;
  DBMS_OUTPUT.put_line(cnt);
end;

---

declare
  dt date := sysdate;
  dtt timestamp := sysdate;
  cnt number;
  dtc varchar2(99);
begin
   execute immediate 'alter session set nls_date_format = ''DD-MON-YY HH:MI:SS AM''';

  update zbob set actual_updated=sysdate-interval '12' hour where rownum < 5; commit;
  
   DBMS_OUTPUT.put_line('now ' || dt);
   DBMS_OUTPUT.put_line('now ' || dtt);
 
   dt := sysdate - interval '13' hour;
   DBMS_OUTPUT.put_line('yesterday ' || dt);
   dtt := sysdate - interval '13' hour;
   DBMS_OUTPUT.put_line('yesterday ' || dtt);
   
   execute immediate 'select count(1) from zbob where actual_updated > :1' into cnt using dt;
   DBMS_OUTPUT.put_line(cnt);
   
   execute immediate 'select count(1) from zbob where actual_updated > :1' into cnt using dtt;
   DBMS_OUTPUT.put_line(cnt);
   
   dtc := to_char(dt,'DD-MON-YY HH:MI:SS AM');
   dbms_output.put_line(dtc);
 
   execute immediate 'select count(1) from zbob where actual_updated > ' || chr(39) || dtc || chr(39)   into cnt;
   dbms_output.put_line(cnt);
end;
