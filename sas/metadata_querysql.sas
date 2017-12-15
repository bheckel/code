options ls=180;
libname l 'x:/sql_loader/metadata';
proc sql;
  select meth_peak_nm format=$10., summary_meth_stage_nm format=$15.,
  lab_tst_desc format=$15.,
  meth_rslt_numeric, indvl_meth_stage_nm, indvl_tst_rslt_row,
  indvl_tst_rslt_device format=$15., indvl_tst_rslt_val_num
  from l.lemetadata_advairhfa
  where meth_spec_nm like 'ATM02063%' and samp_id=204098
  order by meth_peak_nm, summary_meth_stage_nm
  ;
run;
proc sql;
  select meth_peak_nm format=$10., summary_meth_stage_nm format=$15.,
  lab_tst_desc format=$15.,
  meth_rslt_numeric, indvl_meth_stage_nm, indvl_tst_rslt_row,
  indvl_tst_rslt_device format=$15., indvl_tst_rslt_val_num
  from l.lemetadata_advairhfa
  where meth_spec_nm like 'ATM02063%' and samp_id=201293
  order by meth_peak_nm, summary_meth_stage_nm
  ;
run;
endsas;
proc sql;
  select meth_peak_nm format=$5., summary_meth_stage_nm format=$15.,
  lab_tst_desc format=$15.,
  meth_rslt_numeric, indvl_meth_stage_nm, indvl_tst_rslt_row,
  indvl_tst_rslt_device, indvl_tst_rslt_val_num
  from l.lemetadata_advairhfa
  where meth_spec_nm like 'ATM02064%' and samp_id=202756 and meth_var_nm='CALCWEIGHTSUSPFREECONCTBL'
  order by meth_peak_nm, summary_meth_stage_nm
  ;
run;
proc sql;
  select meth_peak_nm format=$5., summary_meth_stage_nm format=$15.,
  lab_tst_desc format=$15.,
  meth_rslt_numeric, indvl_meth_stage_nm, indvl_tst_rslt_row,
  indvl_tst_rslt_device, indvl_tst_rslt_val_num
  from l.lemetadata_advairhfa
  where meth_spec_nm like 'ATM02064%' and samp_id=200623 and meth_var_nm='CALCWEIGHTSUSPFREECONCTBL'
  order by meth_peak_nm, summary_meth_stage_nm
  ;
run;
