data survey;
  input (Q1-Q5)($1.);
  c = cats(of Q1-Q5);
  num = countc(cats(of Q1-Q5),'y','i');
  datalines;
yynnY
nnnnn
  ;
run;
proc print data=survey width=minimum; run;
