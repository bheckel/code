
 /* Returns about 40 obs for this dataset */
data t;
  do pickit=1 to nobs by 10;  /* i.e. roughly 10% */
    set sashelp.shoes point=pickit nobs=nobs;
    output;
  end;
  stop;
run;
proc print data=_LAST_(obs=max) width=minimum; run;
