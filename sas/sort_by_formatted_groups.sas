 /* Sort by formatted groups */

proc format;
   value myrange
      low -55 = 'Under 55'
      55-60   = '55 to 60'
      60-65   = '60 to 65'
      65-70   = '65 to 70'
      other   = 'Over 70';
run;

proc sort data=sashelp.class out=sorted_class; by height; run;
title "&SYSDSN";proc print data=_LAST_(obs=10) width=minimum heading=H;run;title;

data _null_;
   format height myrange.;
   set sorted_class;

   by height GROUPFORMAT;

   if first.height then put '!!! Shortest in ' height 'measures ' height:best12.;
run;
/*
Obs    Name       Sex    Age    Height    Weight

  1    Joyce       F      11     51.3       50.5
  2    Louise      F      12     56.3       77.0
  3    Alice       F      13     56.5       84.0
  4    James       M      12     57.3       83.0
  5    Thomas      M      11     57.5       85.0
  6    John        M      12     59.0       99.5
  7    Jane        F      12     59.8       84.5
  8    Janet       F      15     62.5      112.5
  9    Jeffrey     M      13     62.5       84.0
 10    Carol       F      14     62.8      102.5
*/
