
data t(keep=sales);
  set sashelp.shoes(where=(region='Africa'));
run;

proc means data=t;
  var sales;
run;



data tmp;
  array a[*] n1-n10;

  input a[*];

  m=mean(of a[*]);
  cards;
1 2 3 4 5 6 7 8 9 0
10 20 30 40 50 60 70 80 90 100
  ;
run;
proc print data=_LAST_(obs=max); run;



data tmp;
  array a[*] n1-n10 (1 2 3 4 5 6 7 8 9 0);

  m=mean(of a[*]);
run;
proc print data=_LAST_(obs=max); run;
