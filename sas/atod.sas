libname l 'C:\datapost\data\GSK\Zebulon\MDPI\AdvairDiskus';

data t;
  set l.ods_0302e_advairdiskusH(obs=max);
  td = input(test_date, YYMMDD10.);
run;
proc print data=_LAST_(obs=max) width=minimum; run;
