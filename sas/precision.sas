 /* Display floating point number at different levels of precision */
data _null_;
  indvl_tst_rslt_val_num=1.23456789;
  zerodec =  left(substr(left(put(round(indvl_tst_rslt_val_num,1),8.0)),1));
  onedec =   left(substr(left(put(round(indvl_tst_rslt_val_num,.1),8.1)),1));
  twodec =   left(substr(left(put(round(indvl_tst_rslt_val_num,.01),8.2)),1));
  threedec = left(substr(left(put(round(indvl_tst_rslt_val_num,.001),8.3)),1));
  fourdec =  left(substr(left(put(round(indvl_tst_rslt_val_num,.0001),8.4)),1));
  put (_all_)(=/);
run;
