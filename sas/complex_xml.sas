options ls=180;

filename MAP "t2b.map";
libname XLIB XML "t2.xml" xmlmap=MAP access=READONLY;

data trend; set XLIB.trend; run;
/***proc print data=_LAST_(obs=max) width=minimum; run;  ***/

data linesinfo; set XLIB.linesinfo; run;
proc print data=_LAST_(obs=max) width=minimum; run;  

data line; set XLIB.line; run;
/***proc print data=_LAST_(obs=max) width=minimum; run;  ***/


data tx;
  merge trend linesinfo;
  by trend_ordinal;
run;
title 'XXXXXXXXX';proc print data=_LAST_(obs=max) width=minimum; run;  
data txx;
  merge tx line;
  by linesinfo_ordinal;
run;
title 'YYYYYYYY';proc print data=_LAST_(obs=max) width=minimum; run;  

data l.txx; set txx; run;
