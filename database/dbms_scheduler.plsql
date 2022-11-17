--------------------------------------------------------
--  Created: 09-Nov-2020 (Bob Heckel)
-- Modified: 12-Jul-2022 (Bob Heckel)
--
-- DBMS_SCHEDULER.create_job does an implicit COMMIT!
--------------------------------------------------------

-- If the scheduler default_timezone is not specified, it attempts to
-- determine it from the OS. If that isn't possible it is set to NULL. 
SELECT DBMS_SCHEDULER.STIME FROM DUAL;

---

BEGIN
  DBMS_SCHEDULER.create_job(
    job_name   => 'JOB_TESTING',
    job_type   => 'PLSQL_BLOCK',
    job_action => q'[ declare x number; begin select 1 into x from dual; DBMS_OUTPUT.put_line('x: ' || x); end; ]',
    start_date => systimestamp + INTERVAL '3' second,  -- if missing runs immediately
    enabled    => true  -- if false it just sits there DISABLED
  );
END;
SELECT state, NEXT_RUN_DATE, job_name, job_type, job_action, start_date, repeat_interval, end_date, job_class, enabled, auto_drop, comments FROM user_scheduler_jobs WHERE job_name = 'JOB_TESTING';
SELECT errors,output,job_name, status, error#, actual_start_date, run_duration FROM user_scheduler_job_run_details WHERE job_name = 'JOB_TESTING' ORDER BY actual_start_date DESC;

-- If create_job has no start_date:
--26-JAN-22 02.52.02.064495000 PM AMERICA/NEW_YORK
-- If it does:
--26-JAN-22 02.53.19.070618000 PM -05:00

---

BEGIN
  DBMS_SCHEDULER.create_job(
    job_name   => 'JOB_RIONX',
    job_type   => 'PLSQL_BLOCK',
    --job_action => q'[ declare x number; begin select count(1) into x from account; DBMS_OUTPUT.put_line('cnt: ' || x); end; ]',
    job_action => q'[ begin 
                        execute immediate 'create table mkc_revenue_full_TST as select * from mkc_revenue_full_TST@ests';
                        execute immediate 'create table mkc_revenue_full_POC as select * from mkc_revenue_full_POC@ests';
                      end;
                  ]',
    --start_date => systimestamp + INTERVAL '1' MINUTE,
    --start_date => TO_DATE('10/19/2021 03:18:00 PM', 'mm/dd/yyyy hh:mi:ss PM'),
    start_date => systimestamp + INTERVAL '30' second,
    job_class  => 'DEFAULT_JOB_CLASS',
    enabled    => TRUE,
    comments   => 'One-time run by bheck');
END;
--scheduled/running?
SELECT state, NEXT_RUN_DATE, job_name, job_type, job_action, start_date, repeat_interval, end_date, job_class, enabled, auto_drop, comments FROM user_scheduler_jobs WHERE job_name like 'JOB_RIONX%';
--finished status
SELECT job_name, status, error#, errors, actual_start_date, run_duration, output, errors FROM user_scheduler_job_run_details WHERE job_name like 'JOB_RIONX%' ORDER BY actual_start_date DESC;

---

BEGIN
  sys.dbms_scheduler.create_job(
    job_name => 'TESTJOB1',
    job_type => 'PLSQL_BLOCK',
    job_action => q'[ 
                      BEGIN dbms_output.put_line('ok'); END;
                    ]',
    repeat_interval => 'Freq=Daily;ByDay=MON,TUE,WED,THU,FRI,SUN;ByHour=10;ByMinute=11;BySecond=0',
    job_class => 'DEFAULT_JOB_CLASS',
    enabled => true,
    auto_drop => false,
    comments => 'adhoc');
END;

SELECT state, NEXT_RUN_DATE, job_name, job_type, job_action, start_date, repeat_interval, end_date, job_class, enabled, auto_drop, comments FROM user_scheduler_jobs WHERE job_name like 'TESTJOB1';
SELECT errors,output,job_name, status, error#, actual_start_date, run_duration FROM user_scheduler_job_run_details WHERE job_name like 'TESTJOB1' ORDER BY actual_start_date DESC;

exec DBMS_SCHEDULER.disable('TESTJOB1');
exec DBMS_SCHEDULER.enable('TESTJOB1'); -- this will NOT "catch-up" and run a missed repeat_interval!
exec DBMS_SCHEDULER.stop_job('TESTJOB1'); 
exec DBMS_SCHEDULER.drop_job('TESTJOB1');

---

BEGIN
  -- Run an existing job synchronously. OUTPUT column is null if use_current_session is TRUE!
  DBMS_SCHEDULER.run_job (job_name            => 'TESTJOB1',
                          use_current_session => FALSE);
END;  

---

-- Details of what's scheduled (in job_action), find BEGIN ADD_TSR_OWNERS_TO_RISK; END;
select a.job_name, a.JOB_TYPE, a.JOB_ACTION, a.start_date, a.REPEAT_INTERVAL, a.end_date, a.JOB_CLASS, a.ENABLED, a.AUTO_DROP, a.comments
from user_scheduler_jobs a
where lower(job_action) like '%tsr_%'
order by 1;

-- Named Schedule details.  E.g. schedule_name:PURGE_SCHEDULE repeat_interval:freq=daily;byhour=3;byminute=0;bysecond=0
select * from DBA_SCHEDULER_SCHEDULES d where d.schedule_name like 'P%';
exec DBMS_SCHEDULER.drop_schedule('NIGHTLY_MKC_SCHEDULE');

---

-- Create job (must drop first to avoid error if already exists)
BEGIN
  sys.dbms_scheduler.create_job(
    job_name => 'SETARS.DAILY_DATA_MAINTENANCE_JOB',
    job_type => 'PLSQL_BLOCK',
    job_action => 'begin DAILY_DATA_MAINTENANCE.DAILY_DATA_CHECKS;end;',
    --start_date => cast(SYSTIMESTAMP + (.000694 * wait_minutes) AS TIMESTAMP),
    --start_date => CAST(sysdate + interval '1' minute AS TIMESTAMP),
    start_date => '09-NOV-08 12.01.00AM EST5EDT',
    /* repeat_interval => 'Freq=Daily;ByHour=00;ByMinute=01', */
    --SCHEDULE_TYPE:CALENDAR
    repeat_interval => 'Freq=Daily;ByDay=MON,TUE,WED,THU,FRI,SAT;ByHour=04;ByMinute=30;BySecond=0',
    /* repeat_interval => 'SYSTIMESTAMP + INTERVAL '30' MINUTE', */
    /*repeat_interval => 'FREQ=MINUTELY;INTERVAL=6;',*/
    end_date => to_date(null),
    job_class => 'DEFAULT_JOB_CLASS',
    enabled => true,  -- default FALSE
    -- Jobs are automatically dropped by default after they complete, setting
    -- auto_drop to FALSE causes the job to persist-note that repeating jobs are
    -- not auto-dropped unless the job end date passes, the maximum number of runs
    -- (max_runs) is reached, or the maximum number of failures is reached (max_failures)
    auto_drop  => false,  -- default TRUE
    comments => 'Compiling weekly Maintenance');
END;

-- Cancel scheduled job
BEGIN dbms_scheduler.drop_job('SETARS.DAILY_DATA_MAINTENANCE_JOB'); END;

---

-- Avoid dropping the whole job: 

-- Null out or modify an existing job's attribute
begin
  sys.dbms_scheduler.set_attribute_NULL(name      => 'CREATE_REFERENCE_JOB',
                                        attribute => 'COMMENTS');                                   
end;

-- Update modify an attribute
begin
  sys.dbms_scheduler.set_attribute(name      => 'CREATE_REFERENCE_JOB',
                                   attribute => 'COMMENTS',
                                   value     => 'Nightly job to auto-create reference records not auto-created via the UI');                                   
end;
-- Modify without dropping job and redoing all of it to modify only one attribute
begin
  sys.dbms_scheduler.set_attribute(name      => 'MKC_REVENUE_LOAD_DAVESIM',
                                   attribute => 'JOB_ACTION',
                                   value     => q'[ BEGIN mkc.load_invoice_revenue(in_rediff_tables=>1, in_view_name=>'MKC_REVENUE', in_delete_daily=>1, in_bypass_history=>0); END; ]');                               
end;

-- Modify existing schedule

-- Find NAMED schedule time (START_DATE)
select * from USER_SCHEDULER_SCHEDULES d where d.schedule_name like 'PERI%';

-- Update modify job's NAMED schedule
BEGIN
  sys.dbms_scheduler.set_attribute(name => 'SET_CUSTOMER_FLAG_JOB',
                                   attribute => 'job_action',
                                   value => 'BEGIN SETARS.SET_CUSTOMER_FLAG(inAccount_ID => 0, do_commit =>1); END;');
END;

-- Update change job's NAMED schedule (if job is disabled)
BEGIN sys.Dbms_Scheduler.enable('SETARS.PERIODIC_LIFECYCLE_UPDATE'); END;  -- can pass comma-separated list 'foo, bar'
BEGIN sys.dbms_scheduler.set_attribute(name => 'SETARS.PERIODICLIFECYCLEUPDATE',
                                       attribute => 'START_DATE',
                                       value => '15-NOV-18 09.00.00.856890 AM EST5EDT');
END;
BEGIN sys.dbms_scheduler.set_attribute(name => 'PERIODICLIFECYCLEUPDATE',
                                       attribute => 'REPEAT_INTERVAL',
                                       value => 'Freq=Daily;ByHour=19;ByMinute=00;BySecond=00');
END;
--BEGIN sys.DBMS_SCHEDULER.disable('SETARS.PERIODIC_LIFECYCLE_UPDATE'); END;
-- Stop running job
--exec DBMS_SCHEDULER.STOP_JOB(job_name => 'DEL_JOB_RION44892');

---

CREATE OR REPLACE PACKAGE update_several_jobs AS
  
  PROCEDURE t;

END;
/
CREATE OR REPLACE PACKAGE BODY update_several_jobs AS

  PROCEDURE t
  IS
  
    CURSOR c IS
      select 'SETARS.'||a.job_name full_job_name, a.job_name, a.JOB_ACTION, a.start_date, a.REPEAT_INTERVAL, 
             a.JOB_CLASS, a.ENABLED, a.SCHEDULE_NAME, a.SCHEDULE_TYPE, regexp_replace(a.start_date, ' -\d\d:\d\d.*$', ' EST5EDT') new_start_date
        from all_scheduler_jobs a
       WHERE to_char(a.start_date, 'TZR') !='EST5EDT'
       ORDER BY 2;
    
  BEGIN
    
    FOR j IN c LOOP
      dbms_output.put_line('modifying: ' || rpad(j.full_job_name, 35) || ' ' || j.start_date || ' to ' || j.new_start_date || '    ' || j.schedule_name || ' ' || j.schedule_type);
      
      IF j.schedule_type = 'NAMED' THEN
        dbms_output.put_line('ok1');
        sys.dbms_scheduler.set_attribute(name => j.schedule_name, ATTRIBUTE => 'start_date',VALUE => j.new_start_date);
      ELSIF j.schedule_type = 'CALENDAR' THEN
        dbms_output.put_line('ok2');
        sys.dbms_scheduler.set_attribute(name => j.full_job_name, ATTRIBUTE => 'start_date', VALUE => j.new_start_date);
      END IF;
    END LOOP;
  
  EXCEPTION
    WHEN others THEN
      dbms_output.put_line(SQLCODE || ':' || SQLERRM || ': ' || DBMS_UTILITY.format_error_backtrace);
      RAISE;

  END;  
END;
/

---

-- Adapted https://www.oratable.com/running-procedures-asynchronously-with-oracle-job-scheduler/
-- Non-critical processing asynchronous
create or replace procedure create_booking(booking_id in varchar2) as 
  begin
    dbms_output.put_line('START create_booking');    
    -- Critical parts of booking: main flow, any failure here must fail the entire booking
    allocate_seats;
    capture_customer_details;
    receive_payment;

    -- Non-critical parts of booking: wrapped in a separate procedure called asynchronously
    dbms_output.put_line('Before post_booking_flow_job');
    -- Post-booking jobs are slow so fork them asynchronously
    dbms_scheduler.create_job (
      job_name   =>  'post_booking_flow_job'||booking_id,
      job_type   => 'PLSQL_BLOCK',
      job_action => 
        'BEGIN 
           post_booking_flow('''||booking_id||''');
         END;',
      enabled   =>  TRUE,  
      auto_drop =>  TRUE, 
      comments  =>  'Non-critical post-booking steps');
    
    dbms_output.put_line('After post_booking_flow_job');  
    dbms_output.put_line('END create_booking');  
end;
/

select client_id, job_type, job_action, enabled, run_count, last_start_date 
FROM all_scheduler_jobs t 
WHERE t.job_name LIKE 'POST%'

select job_name, status
from all_scheduler_job_log
where job_name like 'POST_BOOKING_FLOW_JOB%'
and log_date > sysdate - 1/24
order by log_date desc;

select job_name, status, run_duration
from all_scheduler_job_run_details
where job_name like 'POST_BOOKING_FLOW_JOB%'
and log_date > sysdate - 1/24
order by log_date desc;

---

create table t ( x int );
create  type my_varray as varray(5) of number;

create or replace
procedure load_t(v my_varray) is
begin
  for i in 1 .. v.count loop
     insert into t values (v(i));
  end loop;
  commit;
end;

begin
  dbms_scheduler.create_program (
    program_name        => 'pgm_load_t',
    program_type        => 'stored_procedure',
    program_action      => 'load_t',
    number_of_arguments => 1,
    enabled             => false,
    comments            => 'program to run a stored procedure.');

  dbms_scheduler.define_program_argument (
    program_name      => 'pgm_load_t',
    argument_name     => 'v',
    argument_position => 1,
    argument_type     => 'my_varray');

  dbms_scheduler.enable (name => 'pgm_load_t');
end;

declare
  v my_varray := my_varray(1,2,3,4);
  a sys.anydata := SYS.ANYDATA.ConvertCollection(v);
begin
  dbms_scheduler.create_job (
    job_name      => 'job_load_t',
    program_name  => 'pgm_load_t',
    start_date      => SYSTIMESTAMP,
    enabled         => false,
    comments        => 'Job to run pgm');

dbms_scheduler.set_job_anydata_value (
   job_name           => 'job_load_t',
   argument_position  => 1,
   argument_value     => a
   );

 dbms_scheduler.enable ('job_load_t');
end;

select * from t;

drop table t;
drop type my_varray;
drop procedure load_t;
SELECT * from user_scheduler_jobs WHERE job_name like 'JOB_LOAD_%';
SELECT * FROM user_SCHEDULER_JOB_RUN_DETAILS WHERE JOB_NAME  like 'JOB_LOAD_%' order by log_date desc;

---

-- Deprecated, no implicit commit
DBMS_JOB.submit(job_num,
                'BEGIN SHADOW_INDEX(''ACCOUNT_SEARCH_BING_IX'', 1, 1, 1); END;',
                 SYSDATE,
                 NULL);
COMMIT;                 

SELECT * FROM user_jobs WHERE job=6744;

---

BEGIN
   -- Drop the job, if exists
   BEGIN
     SYS.DBMS_SCHEDULER.DROP_JOB(job_name  => 'LONG_RUNNING_USER_QUERIES_JOB');
   EXCEPTION
     WHEN OTHERS THEN
       NULL;
   END;

   -- Drop the schedule, if exists
   BEGIN
     SYS.DBMS_SCHEDULER.DROP_SCHEDULE(
       schedule_name  => 'LONG_RUNNING_USER_QUERIES_SCH');
   EXCEPTION
     WHEN OTHERS THEN
       NULL;
   END;

   DBMS_SCHEDULER.create_schedule(
      schedule_name   => 'LONG_RUNNING_USER_QUERIES_SCH',
      repeat_interval => 'FREQ=DAILY;BYHOUR=6;BYMINUTE=0;BYSECOND=0',
      comments        => 'Schedule for long running user queries job.');

   DBMS_SCHEDULER.create_job(
      job_name            => 'LONG_RUNNING_USER_QUERIES_JOB',
      schedule_name       => 'LONG_RUNNING_USER_QUERIES_SCH',
      job_type            => 'PLSQL_BLOCK',
      job_action          => 'BEGIN SETARS.long_running_user_queries(20); END;',
      enabled             => TRUE,
      comments            => 'Job to email long running queries to the respective users. Runs every day at 6am.');
END;

---

-- Turn a call into a delayed job
PROCEDURE send_cdhub_job_message(in_job_action VARCHAR2,
                                 in_job_prefix VARCHAR2,
                                 in_start_date DATE DEFAULT SYSDATE + INTERVAL '3' MINUTE) IS
  PRAGMA AUTONOMOUS_TRANSACTION;

BEGIN
  -- Create a unique job name for the job e.g. FOO_12345
  DBMS_SCHEDULER.CREATE_JOB(job_name   => DBMS_SCHEDULER.GENERATE_JOB_NAME('foo_'),
                            job_type   => 'PLSQL_BLOCK',
                            job_action => 'BEGIN ' || in_job_action || '; END;',
                            start_date => CAST(in_start_date AS TIMESTAMP),
                            enabled    => TRUE,
                            auto_drop  => TRUE);
END;

---

      v_start := SYSDATE || ' 10.00.00PM EST5EDT';
      DBMS_SCHEDULER.CREATE_JOB(job_name   => 'JOB_LOAD_HISTORY',
                                job_type   => 'PLSQL_BLOCK',
                                job_action => 'begin MKC_bob.load_history(in_job_start_time => trunc(SYSDATE)); end;',
                                start_date => v_start,
                                enabled    => TRUE,
                                auto_drop  => TRUE,
                                comments   => 'NEW BUILD HIST ' || v_main_table);
---

-- Weekly schedule
BEGIN
  sys.dbms_scheduler.create_job(
    job_name => 'JOB_LOAD_NB_TEST',
    job_type => 'PLSQL_BLOCK',
    --job_action => 'BEGIN mkc.load_invoice_revenue(in_wait_for_perc=>0, in_rediff_tables=>1, in_view_name=>''MKC_REVENUE2'', in_delete_daily=>1, in_bypass_history=>0); END;',
    job_action => 'BEGIN null; END;',
    --start_date => '03-JUN-21 04.00.00PM EST5EDT',
    repeat_interval => 'Freq=Daily;ByDay=MON,TUE,WED,THU,FRI,SAT;ByHour=16;ByMinute=00;BySecond=0',
    end_date => to_date(null),
    job_class => 'DEFAULT_JOB_CLASS',
    enabled => true,
    auto_drop => false,
    comments => 'testing');
END;
exec sys.DBMS_SCHEDULER.drop_job('JOB_LOAD_NB');
exec DBMS_SCHEDULER.disable('JOB_LOAD_NB');
exec DBMS_SCHEDULER.enable('JOB_LOAD_NB');
-- Only To: is filled. Notifs autodrop when BEGIN dbms_scheduler.drop_job('JOB_LOAD_NB'); END;
begin
  dbms_scheduler.add_job_email_notification (
  job_name=> 'JOB_LOAD_NB',
  sender => 'noreply@s.com',
  recipients=> 'bob@s.com,bruce@s.com',
  subject => '[MKC] Oracle Scheduler Job Notification - %job_owner%.%job_name%.%job_subname% on SER: %event_type%',
  events=> 'job_started, job_succeeded, job_failed, job_broken, job_disabled');
end;
begin
  dbms_scheduler.remove_job_email_notification (
  job_name=> 'JOB_LOAD_NB',
  recipients=> 'bob@s.com,bruce@s.com',
  events=> 'job_started, job_succeeded, job_failed, job_broken, job_disabled');
end;

SELECT * FROM user_scheduler_notifications WHERE job_name = 'JOB_LOAD_NB' and event='JOB_STARTED';
-- or
SELECT DISTINCT NOTIFICATION_OWNER, JOB_NAME, RECIPIENT,
                LISTAGG(event, ', ' ON OVERFLOW TRUNCATE '...' WITHOUT COUNT) WITHIN GROUP (ORDER BY recipient) over ( partition by recipient ) event_list
FROM user_scheduler_notifications
WHERE job_name = 'JOB_LOAD_NB_POC';

---

-- Will run when DB is restarted
begin
  DBMS_SCHEDULER.set_attribute (
     name           => 'TEST56564',
     attribute      => 'restart_on_recovery',
     value          => true);
end;

---

BEGIN
  sys.dbms_scheduler.create_job(
    job_name => 'JOB_FAILED_LOGINS_' || get_db_name,
    job_type => 'PLSQL_BLOCK',
    job_action => q'[
                      declare
                        l_cnt number := 0;
                      begin
                        select count(1)
                          into l_cnt
                          from dba_audit_trail
                         where returncode=1017 and timestamp > sysdate - interval '20' minute;
                      
                        dbms_output.put_line(l_cnt);
                        
                        if l_cnt > 0 then
                          e_mail_message@RION_PROD_RW('replies-disabled@sas.com',
                                                       'Bob.Heckel@as.com,Bru',
                                                       'Job JOB_FAILED_LOGINS_' || get_db_name || ': Failed login attempts on ' || get_db_name,
                                                       l_cnt || ' tries so far');
                        end if;
                      end; 
                    ]',
    --start_date => systimestamp + INTERVAL '9' SECOND,
    start_date => SYSTIMESTAMP,
    repeat_interval => 'Freq=Minutely;Interval=20',
    enabled => true,
    auto_drop  => false,
    comments => 'bheck');
END;

---

-- Run only one job at a time, no overlapping (which could cause deadlocks)
--  set serveroutput on size 500000
DECLARE
  l_jobs_running_count NUMBER;
  l_dbms_job_action    VARCHAR2(500);
  l_dbms_job_name      VARCHAR2(500);
  l_dbms_job_comment   VARCHAR2(1000);
  l_dbms_job_prefix    VARCHAR2(30) := 'ASP_REFRESH_';
  l_refresh_sp_name    VARCHAR2(50) := 'ASP_PKG.MERGE_ASP_TERRITORY_PER_EMP';

  lRequestId VARCHAR2(500) := 'ASP_PKG.MERGE_ASP_TERRITORY_PER_EMP - ' ||
                             TO_CHAR(sysdate, 'YYYYMMDD HH24:MI:SS');
  PRAGMA AUTONOMOUS_TRANSACTION;

  BEGIN
    SELECT COUNT(1)
      INTO l_jobs_running_count
      FROM USER_SCHEDULER_RUNNING_JOBS
     WHERE JOB_NAME LIKE l_dbms_job_prefix || '%';

    IF (l_jobs_running_count > 0) THEN
      -- A refresh jobs is already running. No need to add one more.
      RETURN;
    END IF;

    l_dbms_job_name    := DBMS_SCHEDULER.generate_job_name(l_dbms_job_prefix);
    l_dbms_job_comment := 'Job (' || l_dbms_job_name ||
                          ') for refresh of  ASP_TERRITORY_PER_EMPLOYEE Table.';
    l_dbms_job_action  := 'begin dbms_session.sleep(30); dbms_output.put_line(''ok''); end;';

    DBMS_SCHEDULER.create_job(job_name   => l_dbms_job_name,
                              job_type   => 'PLSQL_BLOCK',
                              job_action => l_dbms_job_action,
                              end_date   => NULL,
                              enabled    => TRUE,
                              auto_drop  => TRUE,
                              job_class  => MAINT_TYPES.ROION_JOB_CLASS,
                              comments   => l_dbms_job_comment);

    dbms_output.put_line('x'||l_jobs_running_count); 

  EXCEPTION
    WHEN OTHERS THEN
      e_mail_message('replies-disabled@as.com',
                     'bob.heckel@as.com',
                     '[SP] Error in ' || l_refresh_sp_name,
                     'Error running ' || l_refresh_sp_name || SQLCODE || ':' ||
                     SQLERRM || ': ' || DBMS_UTILITY.format_error_backtrace);

      RAISE_APPLICATION_ERROR(-20700,
                              l_refresh_sp_name || SQLCODE || ':' ||
                              SQLERRM || ': ' ||
                              DBMS_UTILITY.format_error_backtrace);
END;
