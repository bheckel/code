
-- Modified: Mon 09-Sep-2019 (Bob Heckel)

-- Details of what's scheduled (in job_action)
select a.job_name, a.JOB_TYPE, a.JOB_ACTION, a.start_date, a.REPEAT_INTERVAL, a.end_date, a.JOB_CLASS, a.ENABLED, a.AUTO_DROP, a.comments
from all_scheduler_jobs a ORDER BY 1

-- Next run details
SELECT * from user_scheduler_jobs@sed WHERE job_name in ('PERIODIC_LIFE_UPDATE')
-- Run status log
SELECT * FROM ALL_SCHEDULER_JOB_RUN_DETAILS WHERE JOB_NAME LIKE 'PTG%' order by log_id desc
-- Named Schedule details
select * from DBA_SCHEDULER_SCHEDULES d where d.schedule_name like 'PERI%';

---

BEGIN
 sys.dbms_scheduler.create_job(
   job_name        => 'ASP_TO_ATAA_JOB',
   job_type        => 'PLSQL_BLOCK',
   --job_action => 'begin null; ASP_PKG.update_ataa_with_asp(p_do_commit => 0); end;',
   job_action      => 'begin null; end;',
   repeat_interval => 'FREQ=MINUTELY; INTERVAL=60',
   end_date        => TO_DATE(NULL),
   job_class       => 'DEFAULT_JOB_CLASS',
   enabled         => TRUE,
   comments        => 'Stage approved ASP records to ATAA');
END;

SELECT * from user_scheduler_jobs WHERE job_name='ASP_TO_ATAA_JOB';
SELECT * FROM user_SCHEDULER_JOB_RUN_DETAILS WHERE JOB_NAME = 'ASP_TO_ATAA_JOB';

---

-- ALL_SCHEDULER_JOBS.SCHEDULE_TYPE = 'ONCE' is default
BEGIN
 sys.dbms_scheduler.create_job(
   job_name   => 'TEST_JOB',
   job_type   => 'PLSQL_BLOCK',
   job_action => 'begin null;end;',
   start_date => CAST(SYSDATE + interval '1' minute AS TIMESTAMP),
   end_date   => TO_DATE(NULL),
   job_class  => 'DEFAULT_JOB_CLASS',
   enabled    => TRUE,
   comments   => 'One time run, auto drops');
END;
-- DBMS_SCHEDULER.create_job does an implicit COMMIT

---

-- https://docs.oracle.com/cd/B19306_01/server.102/b14231/scheduse.htm#i1019182
BEGIN  
  DBMS_SCHEDULER.create_schedule(
    schedule_name   => 'AUTO_ACCEPT_TARGETS_SCHEDULE',
    repeat_interval => 'FREQ=MINUTELY; INTERVAL=5;',
    end_date        => TO_DATE(NULL),
    comments        => 'Schedule for auto_acknowledge_targets job.');
END;

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
    /* repeat_interval => 'SYSTIMESTAMP + INTERVAL '30' MINUTE', */
    repeat_interval => 'FREQ=MINUTELY;INTERVAL=6;',
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

-- Drop job
BEGIN dbms_scheduler.drop_job('SETARS.DAILY_DATA_MAINTENANCE_JOB'); END;

---

-- Update job
BEGIN sys.dbms_scheduler.set_attribute(name => 'SET_CUSTOMER_FLAG_JOB', ATTRIBUTE => 'job_action', VALUE => 'BEGIN SETARS.SET_CUSTOMER_FLAG(inAccount_ID => 0, do_commit =>1); END;'); END;

-- Update job (if disabled)
BEGIN sys.Dbms_Scheduler.enable('SETARS.PERIODIC_LIFECYCLE_UPDATE'); END;  -- can pass comma-separated list 'foo, bar'
BEGIN sys.dbms_scheduler.set_attribute(name => 'SETARS.PERIODICLIFECYCLEUPDATE', ATTRIBUTE => 'start_date',VALUE => '15-NOV-18 09.00.00.856890 AM EST5EDT');END;
BEGIN sys.Dbms_Scheduler.disable('SETARS.PERIODIC_LIFECYCLE_UPDATE'); END;

---

CREATE OR REPLACE PACKAGE orion33427 AS
  
  PROCEDURE t;

END;
/
CREATE OR REPLACE PACKAGE BODY orion33427 AS

  PROCEDURE t
  IS
  
    CURSOR c IS
      select 'ESTARS.'||a.job_name full_job_name, a.job_name, a.JOB_ACTION, a.start_date, a.REPEAT_INTERVAL, 
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
