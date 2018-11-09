--SELECT * FROM ALL_SCHEDULER_JOB_RUN_DETAILS WHERE JOB_NAME LIKE 'PTG%'

-- Drop job
 dbms_scheduler.drop_job('SETARS.DAILY_DATA_MAINTENANCE_JOB');

-- Recreate job
sys.dbms_scheduler.create_job(
  job_name => 'SETARS.DAILY_DATA_MAINTENANCE_JOB',
  job_type => 'PLSQL_BLOCK',
  job_action => 'begin DAILY_DATA_MAINTENANCE.DAILY_DATA_CHECKS;end;',
  start_date => '09-NOV-08 12.01.00AM EST5EDT',
  repeat_interval => 'Freq=Daily;ByHour=00;ByMinute=01',
  end_date => to_date(null),
  job_class => 'DEFAULT_JOB_CLASS',
  enabled => true,
  auto_drop => false,
  comments => 'Compiling weekly Maintenance(GO_WEEKLY)and check nonusedinsetars_contacts into one package');
end;
