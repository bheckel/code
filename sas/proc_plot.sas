
data djia;
  input Year @7 HighDate date7. High @24 LowDate date7. Low;
  format highdate lowdate date7.;
  datalines;
1990  31DEC90  204.39  11JAN90  279.87
1991  31DEC91  404.39  11JAN91  279.87
1992  30DEC92  488.40  17JAN92  388.20
1993  29DEC93 3794.33  20JAN93 3241.95
1994  31JAN94 3978.36  04APR94 3593.35
1994  31JAN94 3978.36  04APR94 3593.35
  ;
run;
proc print data=_LAST_(obs=max) width=minimum; run;


options nodate pageno=1 linesize=80 pagesize=35;
proc plot data=djia /*NOLEGEND*/;
  plot high*year / haxis=1989 to 1995 by 1 vref=3000;
  plot low*year='o' / haxis=1989 to 1995 by 1 href=1993;
  plot high*year='+' low*year='o' / overlay box;
run;
