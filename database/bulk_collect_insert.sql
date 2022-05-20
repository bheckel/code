-- Modified: 16-May-2022 (Bob Heckel)

select utc1.column_name||','--, utc1.data_default, utc2.data_default
--select 'id_table(i).'||utc1.column_name||','
  from user_tab_cols utc1, user_tab_cols utc2
 where utc1.TABLE_NAME = 'MKC_REVENUE_FULL'
   and utc1.VIRTUAL_COLUMN = 'NO'
   and utc2.TABLE_NAME = 'MKC_REVENUE_FULL'
   and utc2.VIRTUAL_COLUMN = 'NO'
   and utc1.COLUMN_NAME = utc2.COLUMN_NAME
   and utc1.column_name not like 'SYS_%'
  order by utc1.column_id;

DECLARE
  CURSOR c1 IS 
    SELECT UID_KMC_REVENUE_ID.NEXTVAL kmc_revenue_id, ACCOUNT_ID_ADJ,ACCOUNT_ID_AS,ACCOUNT_ID_CW,ACCOUNT_ID_HB,created,createdby
      FROM MKC_REVENUE_FULL;

  TYPE t_idtbl IS TABLE OF c1%ROWTYPE;
  id_table t_idtbl;

  BEGIN
    OPEN c1; 
    LOOP
      FETCH c1 BULK COLLECT INTO id_table limit 1000;
      EXIT WHEN id_table.COUNT = 0;

      FORALL i IN 1 .. id_table.COUNT
        INSERT  INTO MKC_REVENUE_FULL_BOB ( KMC_REVENUE_ID,ACCOUNT_ID_ADJ,ACCOUNT_ID_AS,ACCOUNT_ID_CW,ACCOUNT_ID_HB,created,createdby )
        VALUES ( id_table(i).KMC_REVENUE_ID,id_table(i).ACCOUNT_ID_ADJ,id_table(i).ACCOUNT_ID_AS,id_table(i).ACCOUNT_ID_CW,id_table(i).ACCOUNT_ID_HB,id_table(i).created,id_table(i).createdby );
      COMMIT;
    END LOOP;      
  COMMIT;

EXCEPTION
  WHEN OTHERS THEN
    rollback;
    DBMS_OUTPUT.put_line(SQLCODE || ':' || SQLERRM || ': ' || DBMS_UTILITY.format_error_backtrace);
END;


BEGIN
  dbms_scheduler.create_job(
    job_name => 'MANUAL_RUN_' || get_db_name,
    job_type => 'PLSQL_BLOCK',
    job_action => q'[ 
      --on uat
      DECLARE
        CURSOR c1 IS 
          SELECT *
            FROM ASP_2021@rion_prod_rw;
      
        TYPE t_idtbl IS TABLE OF c1%ROWTYPE;
        id_table t_idtbl;
      
        BEGIN
          OPEN c1; 
          LOOP
            FETCH c1 BULK COLLECT INTO id_table limit 1000;
            EXIT WHEN id_table.COUNT = 0;
      
            FORALL i IN 1 .. id_table.COUNT
              INSERT  INTO asp ( 
                ACCOUNT_ID,ACCOUNT_SITE_ID,FUTURE_TSR_OWNER,FUTURE_TERRITORY,FUTURE_TIER,FUTURE_COVERAGE,FUTURE_SUP_ACCT_ID_DONOTUSE,FUTURE_SUP_ACCOUNT_NAME,FUTURE_SUP_NAICS_CODE,FUTURE_SUP_NAICS_DESC,FUTURE_SUP_ACCOUNT_STATE,FUTURE_TIER_LOV_ID,FUTURE_COVERAGE_LOV_ID,FUTURE_TSR_OWNER_ID,FUTURE_TERRITORY_LOV_ID,FUTURE_SUP_NAICS_LOV_ID,COMMENTS,FUTURE_TSR_OWNER_LN,FUTURE_TSR_OWNER_FN,FUTURE_TSR_OWNER_GONE,ASP_ID,SPLIT_WITHOUT_EXCLUSIONS,SPLIT_WITH_EXCLUSIONS,CREATED,CREATEDBY,UPDATED,UPDATEDBY,H_VERSION,ACTUAL_UPDATED,ACTUAL_UPDATEDBY,RETIRED_TIME,AUDIT_SOURCE,FUTURE_SUP_ACCOUNT_ID,FUTURE_SUP_ACCOUNT_COUNTY,SUP_SPLIT_WITH_EXCLUSIONS,SUP_SPLIT_WITHOUT_EXCLUSIONS,CURRENT_QUADRANT_LOV_ID
              )
              VALUES ( 
                id_table(i).ACCOUNT_ID,id_table(i).ACCOUNT_SITE_ID,id_table(i).FUTURE_TSR_OWNER,id_table(i).FUTURE_TERRITORY,id_table(i).FUTURE_TIER,id_table(i).FUTURE_COVERAGE,id_table(i).FUTURE_SUP_ACCT_ID_DONOTUSE,id_table(i).FUTURE_SUP_ACCOUNT_NAME,id_table(i).FUTURE_SUP_NAICS_CODE,id_table(i).FUTURE_SUP_NAICS_DESC,id_table(i).FUTURE_SUP_ACCOUNT_STATE,id_table(i).FUTURE_TIER_LOV_ID,id_table(i).FUTURE_COVERAGE_LOV_ID,id_table(i).FUTURE_TSR_OWNER_ID,id_table(i).FUTURE_TERRITORY_LOV_ID,id_table(i).FUTURE_SUP_NAICS_LOV_ID,id_table(i).COMMENTS,id_table(i).FUTURE_TSR_OWNER_LN,id_table(i).FUTURE_TSR_OWNER_FN,id_table(i).FUTURE_TSR_OWNER_GONE,id_table(i).ASP_ID,id_table(i).SPLIT_WITHOUT_EXCLUSIONS,id_table(i).SPLIT_WITH_EXCLUSIONS,id_table(i).CREATED,id_table(i).CREATEDBY,id_table(i).UPDATED,id_table(i).UPDATEDBY,id_table(i).H_VERSION,id_table(i).ACTUAL_UPDATED,id_table(i).ACTUAL_UPDATEDBY,id_table(i).RETIRED_TIME,id_table(i).AUDIT_SOURCE,id_table(i).FUTURE_SUP_ACCOUNT_ID,id_table(i).FUTURE_SUP_ACCOUNT_COUNTY,id_table(i).SUP_SPLIT_WITH_EXCLUSIONS,id_table(i).SUP_SPLIT_WITHOUT_EXCLUSIONS,id_table(i).CURRENT_QUADRANT_LOV_ID
              );
            COMMIT;
          END LOOP;      
        COMMIT;
        
        e_mail_message('replies-disabled@sas.com',
                       'bob.heckel@s.com',
                       'Job MANUAL_RUN done on '  || get_db_name, SQLCODE || ': ' || SQLERRM || ': ' || DBMS_UTILITY.format_error_backtrace);
      EXCEPTION
        WHEN OTHERS THEN
          rollback;
          DBMS_OUTPUT.put_line(SQLCODE || ':' || SQLERRM || ': ' || DBMS_UTILITY.format_error_backtrace);
      END;
    ]',
    start_date => systimestamp + INTERVAL '10' SECOND,
    enabled => true,
    comments => 'manual - do not kill');
END;
-- exec DBMS_SCHEDULER.drop_job(job_name => 'MANUAL_RUN_ORNDBxRW01');  exec DBMS_SCHEDULER.stop_job(job_name => 'MANUAL_RUN_ORNDBxRW01');
SELECT state, NEXT_RUN_DATE, job_name, job_type, job_action, start_date, repeat_interval, end_date, job_class, enabled, auto_drop, comments FROM user_scheduler_jobs WHERE job_name like 'MANUAL_RUN%';
SELECT job_name, status, error#, actual_start_date, run_duration, output, errors FROM user_scheduler_job_run_details WHERE job_name like 'MANUAL_RUN%' ORDER BY actual_start_date DESC;
