-- Created: 21-Apr-2021 (Bob Heckel)

--...
    v_sql := 
      'select count(1) from (
         with v as (
           select distinct column_name
             from user_ind_columns
            where table_name = ''' || v_main_table || ''' 
              and column_name in (' || v_predicate || ') 
         )
         select listagg(column_name, '','') within group (order by rownum) x
         from v
       ) t
        where t.x  = ' || '''' ||  v_predicate2 || ''''
    ;

    EXECUTE IMMEDIATE v_sql INTO v_ix_exists;

    IF v_ix_exists = 0 THEN
      v_job_action := 'BEGIN EXECUTE IMMEDIATE ''CREATE INDEX KRB_ADD_JOIN_' || v_tableName || 
                      ' ON ' || v_main_table || '(' || v_create_cols || ')''; END;';
      log('AUTO_JOIN', v_job_action);

      BEGIN
        SELECT count(1)
          INTO v_jobcount
          FROM DBA_SCHEDULER_JOBS t
         WHERE t.state = 'RUNNING'
           AND t.comments = in_table_name;

        IF (v_jobcount != 0) THEN
          log('ADD_JOIN_INDEXES failed - ' || in_table_name,
              'Found running job of same name');
          RETURN;
        END IF;

        -- Delay CREATE INDEX to avoid interfering with this build run
        DBMS_SCHEDULER.CREATE_JOB(job_name   => 'JOB_' || v_tableName,
                                  job_type   => 'PLSQL_BLOCK',
                                  job_action => v_job_action,
                                  start_date => SYSDATE + interval '2' hour,
                                  enabled    => TRUE,
                                  auto_drop  => TRUE,
                                  comments   => in_table_name);
      EXCEPTION
        WHEN OTHERS THEN
          -- Allow USER_SCHEDULER_JOB_RUN_DETAILS OUTPUT column to populate with errors
          DBMS_OUTPUT.put_line(SQLCODE || ':' || SQLERRM || ': ' || DBMS_UTILITY.format_error_backtrace);
      END;
    END IF;
  END add_join_indexes;
