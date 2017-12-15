
data dose;
  input Patno Dose Ds_Date :DATE9. Cycle  @41 DoseNum $6.;
  cards;
101     50      15-Nov-05       1       Dose 1  /* no AE */
101     50      16-Nov-05       1       Dose 2  /* no AE */
101     50      17-Nov-05       1       Dose 3  /* AE */
101     80      6-Dec-05        2       Dose 1  /* AE */
101     80      7-Dec-05        2       Dose 2
101     80      8-Dec-05        2       Dose 3
101     20      17-Jan-06       3       Dose 1
101     20      18-Jan-06       3       Dose 2
101     20      19-Jan-06       3       Dose 3
101     60      7-Feb-06        4       Dose 1
101     60      8-Feb-06        4       Dose 2
101     60      9-Feb-06        4       Dose 3
102     100     7-Dec-05        1       Dose 1
102     100     8-Dec-05        1       Dose 2
102     100     9-Dec-05        1       Dose 3
102     100     10-Jan-06       2       Dose 1
102     100     11-Jan-06       2       Dose 2
102     100     12-Jan-06       2       Dose 3
  ;
run;
proc print data=_LAST_(obs=max) width=minimum; run;


data ae;
  input Patno AESTD :DATE9.;
  cards;
101             1-Jan-06
101             7-Feb-06
101             17-Nov-05
101             17-Nov-05
101             6-Dec-05
101             6-Dec-05
101             8-Dec-05
101             16-Dec-05
101             17-Jan-06
101             16-Jan-06
101             16-Jan-06
101             10-Jan-06
101             3-Jan-06
101             9-Jan-06
101             9-Jan-06
102             9-Jan-06
102             9-Jan-06
102             30-Jan-06
102             20-Dec-05
102             22-Dec-05
102             19-Dec-05
102             21-Dec-05
102             22-Dec-05
102             28-Dec-05
102             9-Jan-06
  ;
run;
proc print data=_LAST_(obs=max) width=minimum; run;


 /* Not good enough */
options NOlabel;
proc sql PRINT;
  select *, aestd format=DATE9.
  from ae a LEFT JOIN dose d on d.patno=a.patno and
                                d.ds_date=a.aestd
                                ;
quit;


/* This is a typical assign dose to ae task */

proc sort data=dose out=dose (rename=(ds_date=dt));
  by patno ds_date;
run;
proc sort data=ae out=ae (rename=(aestd=dt));
  by patno aestd;
run;
data aedose;
  retain dose_t cycle_t dosenum_t;
  length dosenum_t $10;
  merge ae(in=inae) dose;
  by patno dt;

  if first.patno then do;
    dose_t=.;
    cycle_t=.;
    dosenum_t='';
  end;

  if ^missing(dose) then do;
    dose_t=dose;
    cycle_t=cycle;
    dosenum_t=dosenum;
  end;
  else do;
    dose=dose_t;
    cycle=cycle_t;
    dosenum=dosenum_t;
  end;

  if inae;

  drop dose_t cycle_t dosenum_t;
  rename dt=aestd;
run;

proc sort data=aedose;
  by patno cycle dosenum;
run;
data aedose; 
  retain patno dose cycle dosenum aestd; 
  set aedose; 
  format aestd DATE9.;
run;
proc print data=_LAST_(obs=max) width=minimum; run;
