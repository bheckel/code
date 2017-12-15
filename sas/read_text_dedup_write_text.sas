
data t;
  infile cards dlm='|';
  input a :$10. b :$10. c :$10. d :$20.;
  cards;
22129240|4|3|2017-03-15
22129250|4|3|2017-03-15
22129277|4|3|2017-03-15
22129277|4|3|2017-03-15
22129294|4|5|2017-03-15
  ;
run;
title "&SYSDSN";proc print data=_LAST_(obs=10) width=minimum heading=H;run;title;

proc sort nodupkey out=t2;
  by a;
run;
title "&SYSDSN";proc print data=_LAST_(obs=10) width=minimum heading=H;run;title;

proc export data=t2 outfile='junk' dbms=dlm replace;
  delimiter='|';
  putnames=no;
run;
