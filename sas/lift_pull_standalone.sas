
libname l '.';
PROC SQL;
  CONNECT TO ORACLE(USER=ODS_Interimn ORAPW="9ew_8h5348j" BUFFSIZE=25000 READBUFF=25000 PATH="ukdev613" DBINDEX=YES);
    CREATE TABLE l.pull_liftTESTING3 AS SELECT * FROM CONNECTION TO ORACLE (
      SELECT 
             b.mrp_batch_id,
             m.material_description,
             m.mrp_mat_id,
             i.mrp_lot_id,
             l.LIMIT_TYPE,
             s.sample_status,
             s.sample_id,
             s.sample_type,
             sm.method_id,
             sm.method_description,
             t.test_id,
             t.test_variant,
             t.test_version_num,
             t.test_description,
             t.instrument_id,
             tc.component_id,
             tc.test_instance,
             substr(tr.test_execution_date,1,9) test_execution_date,
             tr.analyst_id,
             tr.recorded_text,
             tr.recorded_value,  /* most important of the 3? */
             tr.reported_value,
             tr.test_result_type,
             tr.test_result_datatype,
             tr.replicate_id,
             /* source length for most products is 100 char */
             'LIFT ODS_Interimn@ukdev613                                                                          ' source 
      FROM 
             vw_zebulon_lift_batch b,
             vw_zebulon_lift_material m,
             vw_zebulon_lift_inspection_lot i,
             vw_zebulon_lift_gsk_spec gs,
             vw_zebulon_lift_sample s,
             vw_zebulon_lift_sample_method sm,
             vw_zebulon_lift_test t,
             vw_zebulon_lift_test_component tc,
             vw_zebulon_lift_limit_set l,
             vw_zebulon_lift_test_result tr
      WHERE 
             /* Filters */
             i.inspection_lot_plan_fin_dt > (SYSDATE-700) AND  /* TODO from .ini */
             m.mrp_mat_id in ('10000000008557','10000000008558','4117344','4117352','4151232') AND /* TODO from .ini */
             b.mrp_batch_id not in('9ZM0007') AND  /* TODO from .ini */
/***            tr.recorded_value  ^= 'N/A' AND    ***/
             s.sample_type = 'QC' AND 
             /*lower(l.LIMIT_TYPE) in ('inspec range', 'inspec high', 'inspec low','n/a') AND*/  /* removes duplicate specs TODO true? */

             /* Joins */
             b.batch_id=i.batch_id AND

             m.material_id=b.material_id AND

             gs.gsk_spec_id=m.gsk_spec_id AND
             gs.gsk_spec_version=m.gsk_spec_version AND

             i.inspection_lot_id=s.inspection_lot_id AND

             s.sample_id=sm.sample_id AND

             sm.sample_id=t.sample_id AND
             sm.method_id=t.method_id AND

             t.sample_id=tc.sample_id AND
             t.method_id=tc.method_id AND
             t.test_id=tc.test_id AND
             t.test_version_num=tc.test_version_num AND
             t.test_variant=tc.test_variant AND 
             t.test_instance=tc.test_instance AND

             tc.sample_id=tr.sample_id AND
             tc.method_id=tr.method_id AND
             tc.test_id=tr.test_id AND
             tc.test_version_num=tr.test_version_num AND
             tc.test_variant=tr.test_variant AND
             tc.test_instance=tr.test_instance AND
             tc.component_id=tr.component_id AND 

             tr.sample_id = l.sample_id AND
             tr.method_id = l.method_id AND
             tr.test_id = l.test_id AND
             tr.test_version_num = l.test_version_num AND
             tr.test_variant = l.test_variant AND
             tr.test_instance = l.test_instance AND
             tr.component_id = l.component_id AND
             tr.replicate_id = l.replicate_id AND
             tr.test_result_type = l.TEST_RESULT_TYPE
    );
  DISCONNECT FROM ORACLE;
QUIT;
