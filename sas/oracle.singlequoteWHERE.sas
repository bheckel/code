%let sq=%str(%');
proc sql NOPRINT;
  CONNECT TO ORACLE(USER=&LIFTDBUSR ORAPW="&LIFTDBPW" BUFFSIZE=25000 READBUFF=25000 PATH="&LIFTDB" DBINDEX=YES);

    CREATE TABLE pull_lift_matl AS SELECT * FROM CONNECTION TO ORACLE (
      SELECT 
             material_id,
             material_description,
             mrp_mat_id
      FROM 
             ODS_DIST.vw_zeb_lift_material
      WHERE 
             mrp_mat_id in (&LIFTMRPMATLLIST) /* from .ini */
    );

    SELECT 
             mrp_mat_id  INTO :LIFTMATLLIST separated by "','"  /* wrap all but 1st & last with single quotes for Oracle */
    FROM
             pull_lift_matl
             ;

    CREATE TABLE pull_lift AS SELECT * FROM CONNECTION TO ORACLE (
      SELECT 
             mrp_batch_id,
             material_description,
             material_id,
             mrp_lot_id,
             limit_type,
             substr(sample_creation_date,1,11) sample_creation_date,
             sample_status,
             sample_id,
             sample_type,
             method_id,
             method_description,
             test_id,
             test_variant,
             test_version_num,
             test_description,
             instrument_id,
             component_id,
             test_instance,
             substr(test_execution_date,1,11) test_execution_date,
             analyst_id,
             recorded_text,
             recorded_value,  /* most important of the 3? */
             reported_value,
             test_result_type,
             test_result_datatype,
             replicate_id
      FROM 
             ODS_DIST.vw_zebulon_combined_qcresults
      WHERE 
             sample_creation_date > (SYSDATE - &LIFTDAYSPAST) AND
             material_id in (&sq.&LIFTMATLLIST.&sq) AND  /* wrap  1234','5678','9012  with leading and trailing single quote for Oracle */
             upper(LIMIT_TYPE) in ('INSPEC RANGE','INSPEC HIGH','INSPEC LOW','N/A')
    );

  DISCONNECT FROM ORACLE;
quit;
