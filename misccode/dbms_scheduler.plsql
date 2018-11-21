-- https://docs.oracle.com/cd/B19306_01/server.102/b14231/scheduse.htm#i1019182

-- details
--select a.job_name, a.JOB_TYPE, a.JOB_ACTION, a.start_date, a.REPEAT_INTERVAL, a.end_date, a.JOB_CLASS, a.ENABLED, a.AUTO_DROP, a.comments from all_scheduler_jobs a ORDER BY 1
-- log
--SELECT * FROM ALL_SCHEDULER_JOB_RUN_DETAILS WHERE JOB_NAME LIKE 'PTG%'
-- next run
--SELECT * from user_scheduler_jobs@esd WHERE job_name in ('PERIODIC_LIFECYCLE_UPDATE')

-- Drop job
BEGIN dbms_scheduler.drop_job('SETARS.DAILY_DATA_MAINTENANCE_JOB'); END;

-- Recreate job
BEGIN
  sys.dbms_scheduler.create_job(
    job_name => 'SETARS.DAILY_DATA_MAINTENANCE_JOB',
    job_type => 'PLSQL_BLOCK',
    job_action => 'begin DAILY_DATA_MAINTENANCE.DAILY_DATA_CHECKS;end;',
    start_date => '09-NOV-08 12.01.00AM EST5EDT',
    /* repeat_interval => 'Freq=Daily;ByHour=00;ByMinute=01', */
    /* repeat_interval => 'SYSTIMESTAMP + INTERVAL '30' MINUTE', */
    repeat_interval => 'FREQ=MINUTELY;INTERVAL=6;',
    end_date => to_date(null),
    job_class => 'DEFAULT_JOB_CLASS',
    enabled => true,
    auto_drop => false,  -- run more than once
    comments => 'Compiling weekly Maintenance(GO_WEEKLY)and check nonusedinsetars_contacts into one package');
END;

-- Update job (if disabled)
BEGIN sys.Dbms_Scheduler.enable('SETARS.PERIODIC_LIFECYCLE_UPDATE'); END;  -- can pass comma-separated list 'foo, bar'
BEGIN sys.dbms_scheduler.set_attribute(name => 'SETARS.PERIODICLIFECYCLEUPDATE', ATTRIBUTE => 'start_date',VALUE => '15-NOV-18 09.00.00.856890 AM EST5EDT');END;
BEGIN sys.Dbms_Scheduler.disable('SETARS.PERIODIC_LIFECYCLE_UPDATE'); END;

---

DBMS_SCHEDULER.CREATE_JOB(job_name   => 'SET_DNB_JOB_' || account_id_cnt,
													job_type   => 'PLSQL_BLOCK',
													job_action => 'BEGIN USER_ON_CALL.SET_DNB_AS_INPUTSOURCE(' ||
																					 acct.account_id || ',' ||
																					 request_id_quoted || 
																					 '); END;',
										--start_date => CAST(sysdate + interval '1' minute AS TIMESTAMP),
													start_date => cast(SYSTIMESTAMP + (.000694 * wait_minutes) AS TIMESTAMP),
													enabled    => TRUE,
													auto_drop  => TRUE,
													comments   => 'Set DNB as input source');
