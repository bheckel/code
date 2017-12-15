libname l 'c:/datapost/code';
data l.lims_0001e(rename=(maxts3=maxts9));
  set l.lims_0001e;
  maxts3 = '06APR11:00:15:11'dt;
  basefname = 'LIMS_0002E_Avandamet';
run;
proc print data=_LAST_(obs=max) width=minimum; run;
