
data temperatures;
  input temper days place $;
  datalines;
20  14 abc
30   3 ABD
35   3 ABD
.     16 xxx
12.5        1 abc
40  8 abc
50 10 abc
47.0 6 ABD
  ;
run;
proc print data=_LAST_(obs=max); run;

 /* Temperature numcalc by place (VAR by CLASS) */
proc summary data=temperatures NWAY;
  /* Analysis, continuous, variable(s).  Numerics. */
  var temper;
  /* Classification, categorical, discrete, variable(s).  Non-numerics. */
  class place;
  /* TODO how to avoid temp ds? */
  output out=t N=aN mean=bMean std=cStd median=dMedian min=eMin max=fMax;
run;
proc print data=_LAST_(obs=max); run;

endsas;
                                                                   d
Obs    place    _TYPE_    _FREQ_    aN     bMean       cStd     Median    eMin    fMax

 1      ABD        1         3       3    37.3333     8.7369      35      30.0     47 
 2      abc        1         4       4    30.6250    17.3656      30      12.5     50 
 3      xxx        1         1       0      .          .           .        .       . 
