options fullstimer;

 /* Simpler (but slower) than oracle_sql_tmplt.sas when only a few columns are
  * to be displayed 
  */
libname ORA oracle user=pks password=dev123dba path=usdev388;

%include "&HOME/code/sas/tabdelim.sas";
proc sql;
  create table t as
  select *
  from ORA.pks_extraction_control
  order by prod_nm, meth_spec_nm, meth_var_nm
  ;
quit;
options NOmlogic NOmprint NOsgen;%Tabdelim(WORK.t, 'junk.xls');

endsas;
proc sql;
  select distinct t.meth_spec_nm, s.prod_nm 
  from ORA.tst_rslt_summary t JOIN ORA.samp s  ON t.samp_id=s.samp_id
  ;
quit;

proc sql;
  select meth_spec_nm, pks_extraction_macro, pks_level, count(pks_level)
  from ORA.pks_extraction_control
  where prod_nm like 'Wat%'
  group by meth_spec_nm, pks_extraction_macro, pks_level
  having count(pks_level)>1
  ;
quit;

proc sql;
  select distinct t.meth_spec_nm, s.prod_nm
  from ORA.samp s INNER JOIN ORA.tst_rslt_summary t  ON s.samp_id=t.samp_id
  where prod_nm like 'Wat%'
  ;
quit;

proc sql;
  select distinct t.meth_spec_nm, s.prod_nm
  from ORA.samp s, ORA.tst_rslt_summary t
  where s.samp_id=t.samp_id and prod_nm like 'Wat%'
  ;
quit;

proc sql NOprint feedback;
  select distinct samp_id into :s separated by ','
  from ORA.tst_rslt_summary
  where meth_spec_nm like %upcase('am0656%')
  ;
quit;
%put !!!&s;

proc sql;
  select distinct p.prod_nm, s.matl_nbr, s.batch_nbr
  from ORA.pks_extraction_control p, ORA.samp s, ORA.tst_rslt_summary t
  where t.samp_id=s.samp_id and p.meth_spec_nm=t.meth_spec_nm
  ;
quit;

data onsamponly(keep=samp_id);
  merge ORA.samp(in=s) ORA.indvl_tst_rslt(in=i);
  by samp_id;
  if (s=0 and i=1);
run;
proc print data=_LAST_(obs=1000); run;

proc sql;
  select count(*)
  from ORA.samp
  ;
quit;

proc freq data=ORA.samp (where=(prod_nm='Combivir Tablets'));
  table matl_nbr;
run;

proc sql;
  select distinct meth_var_nm, meth_peak_nm, summary_meth_stage_nm, indvl_meth_stage_nm
  from ORA.stage_translation
  order by meth_var_nm, meth_peak_nm
  ;
quit;

proc sql;
  select meth_spec_nm, meth_var_nm, meth_peak_nm, meth_rslt_numeric, meth_rslt_char
  from ORA.tst_rslt_summary
 /***   where samp_id=178505 ***/
 /***   where meth_spec_nm like 'AM0738%' ***/
  ;
quit;

proc sql;
  select meth_spec_nm, meth_var_nm, meth_peak_nm, indvl_meth_stage_nm, indvl_tst_rslt_nm, indvl_tst_rslt_val_num, indvl_tst_rslt_val_char
  from ORA.indvl_tst_rslt
 /***   where samp_id=178505 ***/
 /***   where meth_spec_nm like 'AM0738%' ***/
  ;
quit;

