
options fullstimer;
filename MAP 'c:/temp/b21_0001e.map';
libname MYXML XML "c:/temp/_wsb21.xml" xmlmap=MAP access=READONLY;
data t;
  set MYXML.characteristic10;
run;
proc print;run;


endsas;
filename MAP 'datapost_configuration.map';
libname MYXML XML "datapost_configuration.xml" xmlmap=MAP access=READONLY;
data t;
  set MYXML.trend;
run;

proc contents; run;

proc print data=_LAST_(obs=max) width=minimum; 
  var ExtractID    LowerAxis     LowerLimit     LowerLimitStage2;
run;
