
data dose;
  input Patno Dose Ds_Date :DATE9. Cycle  @41 DoseNum $10.;
  cards;
101     50      15-Nov-05       1       Dose 1
101     50      16-Nov-05       1       Dose 2
101     50      17-Nov-05       1       Dose 3
101     80      6-Dec-05        2       Dose 1
602     100     3-Jul-07        2       Dose 1
602     100     10-Jul-07       2       Dose 2
  ;
run;
proc print data=_LAST_(obs=max) width=minimum; run;
