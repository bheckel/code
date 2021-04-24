
PROCEDURE auto_exclude_rows IS
  TYPE t_numberTable IS TABLE OF NUMBER;
  TYPE t_varchar2Table IS TABLE OF VARCHAR2(32767);
  TYPE t_dateTable IS TABLE OF DATE;
  
  v_sdm_business_keytbl               t_varchar2Table;
  v_new_tor_indtbl                    t_numberTable;
  v_new_mkc_exclusion_reason_idtbl    t_numberTable;
  v_new_mkc_exclusion_reasontbl       t_varchar2Table;
  v_new_mkc_exclusion_reason_datetbl  t_varchar2Table;
  v_conditiontbl                      t_varchar2Table;
  v_sql                               VARCHAR(32767);
  v_tab_size                          NUMBER;
  v_did_update                        NUMBER;
  updateCursor                        SYS_REFCURSOR;
            
BEGIN
  -- Prepare temp comparison table
  EXECUTE IMMEDIATE 'truncate table MKC_REVENUE_SOURCE_ROWS';

  v_sql := 
    'INSERT INTO MC_REVENUE_SOURCE_ROWS (sdm_business_key, tor_ind, source_db )
       SELECT DISTINCT sdm_business_key, tor_ind, ''SDM_REVENUE'' as source_db
         FROM appedw.sdm_revenue@edw
        WHERE extract(year from report_date) >= ' || get_current_reporting_year() ;
   
  EXECUTE IMMEDIATE v_sql;
  COMMIT;
 
  v_sql := '
    INSERT INTO MKC_REVENUE_SOURCE_ROWS (sdm_business_key, tor_ind, source_db )
      SELECT DISTINCT TRIM(dr."SOURCE_INVOICE_ID"||fr."SOURCE_INVOICE_LINE_ID"||f."SOURCE_FINANCIAL_SYSTEM_CD") as sdm_business_key,
             f.tor_ind, ''INVOICE_FACT'' as source_db
        FROM appedw.invoice_fact@edw f 
        LEFT JOIN APPEDW.INVOICE_DIM_REF@EDW dr
          ON f.invoice_id = dr.invoice_id
        LEFT JOIN APPEDW.INVOICE_FACT_REF@EDW fr
          ON f.invoice_line_id = fr.invoice_line_id
       WHERE extract(year from f.report_date) >= ' || get_current_reporting_year() || '
         AND NOT EXISTS (SELECT 1
                           FROM MKC_REVENUE_SOURCE_ROWS x
                          WHERE x.sdm_business_key = TRIM(dr.SOURCE_INVOICE_ID||fr.SOURCE_INVOICE_LINE_ID||f.SOURCE_FINANCIAL_SYSTEM_CD))';
  EXECUTE IMMEDIATE v_sql;
  COMMIT;

  -- Build UPDATE cursor for the 3 exclusion situations
  v_sql := '
    WITH v as (
     -- 1. SDMBK is gone from upstream (we must exclude it)
     SELECT  sdm_business_key,
             0 new_tor_ind,
             91 new_mkc_exclusion_reason_id, 
             ''SDM_BK no longer in source data'' new_mkc_exclusion_reason, 
             SYSDATE new_mkc_exclusion_reason_date, 
             ''condition 1'' conditionsrc
       FROM (
             SELECT krf.sdm_business_key,
                    krf.source_db,
                    krf.mkc_exclusion_reason_id,
                    krf.report_date_adj, krf.report_date_sr, krf.report_date_f
              FROM mkc_revenue_full krf
                WHERE NOT EXISTS ( select 1 
                                  from appedw.sdm_revenue@edw src
                                 where krf.sdm_business_key = src.sdm_business_key
                                   and extract(year from src.report_date) >= ' || get_current_reporting_year() || ')
             )
       WHERE extract(year from COALESCE(report_date_adj, report_date_sr, report_date_f)) >= ' || get_current_reporting_year() || '
         AND source_db = ''SDM_REVENUE''
         AND mkc_exclusion_reason_id = -99  -- not already excluded
      union
      SELECT krf.sdm_business_key, 
             CASE
              -- 2. Indicator has changed to 0 upstream but we show it as not excluded (we must clear the previous exclusion)       
               WHEN krf.mkc_exclusion_reason_id = -99 AND src.tor_ind = 0 THEN
                 0
               -- 3. Indicator has changed back to 1 but we show it as excluded (we must reverse the previous exclusion)           
               WHEN krf.mkc_exclusion_reason_id != -99 AND src.tor_ind = 1 THEN 
                 1
             END AS new_tor_ind,        
             CASE
               WHEN krf.mkc_exclusion_reason_id = -99 AND src.tor_ind = 0 THEN
                 92
               WHEN krf.mkc_exclusion_reason_id != -99 AND src.tor_ind = 1 THEN 
                -99
             END AS new_mkc_exclusion_reason_id,
             CASE
               WHEN krf.mkc_exclusion_reason_id = -99 AND src.tor_ind = 0 THEN
                 ''TOR IND has changed from 1 to 0 in source data''
               WHEN krf.mkc_exclusion_reason_id != -99 AND src.tor_ind = 1 THEN
                 -- No longer excluded
                 NULL
             END AS new_mkc_exclusion_reason,
             CASE
               WHEN krf.mkc_exclusion_reason_id = -99 AND src.tor_ind = 0 THEN
                 TO_DATE(TO_CHAR(TRUNC(sysdate), ''DDMONYY hh:mi:ss pm''),''DDMONYY hh:mi:ss pm'')
               WHEN krf.mkc_exclusion_reason_id != -99 AND src.tor_ind = 1 THEN 
                 NULL
             END AS new_mkc_exclusion_reason_date,      
             ''condition 2 or 3'' conditionsrc
        FROM mkc_revenue_full krf
        LEFT JOIN mkc_revenue_source_rows src
          ON krf.sdm_business_key = src.sdm_business_key
         AND krf.source_db = src.source_db
        WHERE extract(year from COALESCE(report_date_adj, report_date_sr, report_date_f)) >= ' || get_current_reporting_year() || '
    )
  SELECT *
    FROM v
    WHERE new_mkc_exclusion_reason_id IS NOT NULL  -- keep newly identified exclusions only
  ';
  
  OPEN updateCursor FOR v_sql;
    v_did_update := 0;
    LOOP
      FETCH updateCursor BULK COLLECT INTO v_sdm_business_keytbl,
                                           v_new_tor_indtbl,
                                           v_new_mkc_exclusion_reason_idtbl,
                                           v_new_mkc_exclusion_reasontbl,
                                           v_new_mkc_exclusion_reason_datetbl,
                                           v_conditiontbl
                                           LIMIT 500;  
      v_tab_size := v_sdm_business_keytbl.COUNT;
    
      EXIT WHEN v_tab_size = 0;
    
      BEGIN
          FOR i IN 1 .. v_sdm_business_keytbl.COUNT LOOP
            log(v_main_table, 'auto_exclude_rows: ' || v_sdm_business_keytbl(i) || ' new tor_ind: ' ||
                v_new_tor_indtbl(i) || ' new excl id: ' || v_new_mkc_exclusion_reason_idtbl(i) || ' new excl: ' || v_new_mkc_exclusion_reasontbl(i)
                || ' new excl date: ' || v_new_mkc_exclusion_reason_datetbl(i) || ' conditionsrc: ' || v_conditiontbl(i));
          END LOOP;
      
        FORALL i IN 1 .. v_tab_size SAVE EXCEPTIONS
          EXECUTE IMMEDIATE 'UPDATE /*+ NO_PARALLEL*/ ' || v_main_table || '
                                SET tor_ind_sr = :1,
                                    mkc_exclusion_reason_id = :2,
                                    mkc_exclusion_reason = :3,
                                    mkc_exclusion_reason_date = :4,
                                    audit_source = ''MKC.auto_exclude_rows''
                              WHERE sdm_business_key = :5'
                              USING v_new_tor_indtbl(i),
                                    v_new_mkc_exclusion_reason_idtbl(i),
                                    v_new_mkc_exclusion_reasontbl(i),
                                    v_new_mkc_exclusion_reason_datetbl(i),
                                    v_sdm_business_keytbl(i);
    
      EXCEPTION
        WHEN OTHERS THEN
          DBMS_OUTPUT.put_line(DBMS_UTILITY.format_error_stack);   
          DBMS_OUTPUT.put_line('Updated ' || SQL%ROWCOUNT || ' rows prior to EXCEPTION');
  
          FOR ix IN 1 .. SQL%BULK_EXCEPTIONS.COUNT LOOP   
            log(v_main_table, 'ERROR in auto_exclude_rows ' || ix || ' occurred on iteration ' || SQL%BULK_EXCEPTIONS(ix).ERROR_INDEX || '  with error code ' || SQL%BULK_EXCEPTIONS(ix).ERROR_CODE || ' ' || SQLERRM(-(SQL%BULK_EXCEPTIONS(ix).ERROR_CODE)));
          END LOOP;
      END;

      v_did_update := v_did_update + sql%ROWCOUNT;
       
      COMMIT;

    END LOOP; -- updateCursor
  CLOSE updateCursor;

  IF v_did_update > 0 THEN
    e_mail_message('replies-disabled@s.com',
                   'bob.heckel@s.com',
                   '[MKC] New Build auto_exclude_rows executed',
                   '');
  END IF;
END auto_exclude_rows;
