options noreplace;

libname ORA oracle user=pks password=pks path=usdev100;

proc freq data=ORA.links_material;
  tables matl_mfg_dt*matl_typ /nocum;
run;
