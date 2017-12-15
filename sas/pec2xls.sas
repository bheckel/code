***libname ORA oracle user=pks_user password=pksu388 path=ustst388;
libname ORA oracle user=pks password=dev123dba path=usdev388;

%include "&HOME/code/sas/tabdelim.sas";

data t;
  retain meth_spec_nm;  /* want this as col A in xls */
  ***set ORA.pks_extraction_control(where=(prod_nm=:'Advair HFA'));
  ***set ORA.pks_extraction_control(where=(meth_spec_nm in('ATM02064CONTENTHPLC')));
  set ORA.pks_extraction_control;
run;

proc sort data=t;
  by meth_spec_nm meth_var_nm pks_level;
run;

/***%Tabdelim(WORK.t, 'pecadddose.xls');***/
%Tabdelim(WORK.t, 'pec02FEB07.xls');
/***%Tabdelim(WORK.t, 'pec_on_tst_before.xls');***/
/***%Tabdelim(WORK.t, 'pec_on_tst_after.xls');***/

