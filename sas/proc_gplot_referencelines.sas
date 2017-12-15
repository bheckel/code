
goptions reset=all ftext=centb htext=1.5;

/* Create sample data set, A */

data a;
   input year $ y;
   datalines;
90 40
91 85
92 80
93 50
94 90
95 80
;
run;

symbol i=j v=dot c=blue;

axis1 order=(0 to 100 by 25) minor=none reflabel=(j=c '1st reference line' '2nd reference line');

title1 h=5 pct f=swissb 'Sales Report';

proc gplot data=a;
  plot y*year / vaxis=axis1 vref=25 50;
run;
