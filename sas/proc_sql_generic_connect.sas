%let USERNAME=;
%let PASSWORD=;
%let DATABASE=;
%let STARTDT=01JAN11:02:45:11;
%let ENDDT=30MAR12:02:45:11;
%let OUTPUTFILE=junkproc_sql_GDM_LIMS;
%let i=;
%let EXTRACTSTRING=;

%macro SD;
  %let EXTRACTSTRING=
    SELECT b.mat_desc as MATERIAL_DESCRIPTION, a.mrp_mat_id, a.mrp_batch_id, to_char(a.MFG_DT, 'YYYY-MM-DD') AS MFG_DT, 
           to_char(a.last_goods_receipt_dt, 'YYYY-MM-DD') AS last_goods_receipt_dt, a.sample_status, a.test_status as TEST_STATUS, a.long_test_name, 
           a.SHORT_TEST_NAME_LEVEL1, a.SHORT_TEST_NAME_LEVEL2, a.SHORT_TEST_NAME_LEVEL3, a.data_type, a.test_instance, a.replicate_id, a.recorded_text,
           a.reported_value, a.recorded_value, a.test_result_uom, to_char(a.test_end_date, 'YYYY-MM-DD') AS test_date, a.trend_flag, a.instrument_id, 
           a.sample_disposition, a.test_disposition, a.result_number, a.method_id, a.test_id, a.component_id, a.test_result_type, a.test_result_datatype
    FROM gdm_dist.vw_lift_rpt_results_nl a, gdm_dist.VW_MERPS_MATERIAL_INFO b         
    WHERE a.mrp_mat_id = b.mat_cod
    AND a.test_status = 'Approved'
    AND a.MRP_MAT_ID in ('4123468')
    AND a.test_end_date BETWEEN TO_DATE('&STARTDT','DDMONYY:HH24:MI:SS') AND TO_DATE('&ENDDT','DDMONYY:HH24:MI:SS')
    ORDER BY a.MRP_BATCH_ID, b.mat_desc, a.long_test_name
    ;
%mend;

%macro LIMS;
  %let EXTRACTSTRING=
    SELECT DISTINCT R.SampId, R.SampName, R.ResStrVal, R.SampCreateTS, S.SpecName, S.DispName, V.Name, V.DispName as DispName2, SS.SampStatus, PLS.ProcStatus, R.ResLoopIx, R.ResRepeatIx, R.ResReplicateIx
    FROM ProcLoopStat PLS, Result R, SampleStat SS, Var V, Spec S
    WHERE R.SampId IN (SELECT R.SampId
                       FROM Result R, Var V
                       WHERE R.ResStrVal in ('4104501')
                       AND R.SpecRevId=V.SpecRevId AND R.VarId=V.VarId AND V.Name='PRODUCTCODE$')
      AND R.SampCreateTS BETWEEN TO_DATE('&STARTDT','DDMONYY:HH24:MI:SS') AND TO_DATE('&ENDDT','DDMONYY:HH24:MI:SS')
      AND R.SpecRevId = S.SpecRevId
      AND R.SpecRevId = V.SpecRevId
      AND R.VarId = V.VarId
      AND R.SampId = SS.SampId
      AND R.SampId = PLS.SampId
      AND R.ProcLoopId = PLS.ProcLoopId
      AND SS.CurrAuditFlag = 1
      AND SS.CurrCycleFlag = 1
      AND SS.SampStatus <> 20
      AND PLS.ProcStatus >= 16
      AND  R.ResSpecialResultType <> 'C'
      ;
%mend;


/***%SD;***/
%LIMS;
proc sql feedback;
  CONNECT TO ORACLE(USER=&USERNAME ORAPW=&PASSWORD PATH=&DATABASE);
    CREATE TABLE &OUTPUTFILE.&i AS SELECT * FROM CONNECTION TO ORACLE (
      %bquote(&EXTRACTSTRING)
    );
  DISCONNECT FROM ORACLE;
quit;
