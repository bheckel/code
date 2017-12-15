data t;
  input y1-y6;
  cards;
11 55 59 35 25 87
12 79 73 74 86 29
13 80 95 77 25 74
  ;
run;

data t2;
  set t;

  array arr[*] y1-y6;

  max=max(of arr[*]);

  maxidx=whichn(max, of arr[*]);

  maxvarname=vname(arr[maxidx]);
run;
title "&SYSDSN";proc print data=_LAST_(obs=10) width=minimum heading=H;run;title;
/*
Obs    y1    y2    y3    y4    y5    y6    max    maxidx    maxvarname

 1     11    55    59    35    25    87     87       6        y6  
 2     12    79    73    74    86    29     86       5        y5  
 3     13    80    95    77    25    74     95       3        y3  
*/
