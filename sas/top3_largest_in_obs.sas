
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

  array values[*] y1-y6;
  array large[3];  /* top 3 values */
  array names[3] $32;  /* top 3 values variable names */

  do i=1 to 3;
    large[i] = largest(i, of values[*]);
    idx = whichn(large[i], of values[*]);
    names[i] = vname(values[idx]);
  end;
run;
title "&SYSDSN";proc print data=_LAST_(obs=10) width=minimum heading=H;run;title;
/*
Obs    y1    y2    y3    y4    y5    y6    large1    large2    large3    names1    names2    names3    i    idx

 1     11    55    59    35    25    87      87        59        55        y6        y3        y2      4     2 
 2     12    79    73    74    86    29      86        79        74        y5        y2        y4      4     4 
 3     13    80    95    77    25    74      95        80        77        y3        y2        y4      4     4 
*/
