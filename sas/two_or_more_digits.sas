%let DSSOURCE=BF19.NHX0401234.NATMERZ;

 /* Shipment number is 2 or more digits */
data _null_;
  /*                                                     skip 2 digit yr  */
  /*                                                                  ___ */
  fnum=substr(scan("&DSSOURCE",2,'.'),anydigit(scan("&DSSOURCE",2,'.'))+2);
  put fnum=;
run;
