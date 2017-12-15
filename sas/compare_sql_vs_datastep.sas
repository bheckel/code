options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: compare_sql_vs_datastep.sas
  *
  *  Summary: Compare proc sql vs. SAS datastep approaches.
  *
  *  Created: Wed 08 May 2013 10:18:49 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source NOcenter dsoptions=note2err;

/***proc contents data=sashelp.shoes;run;***/

 /* SQL wins if not including a grand total, otherwise SAS wins: */

proc sql;
  title 'proc sql vs. datastep - sql raw';
  select Region, sum(Sales) as Totsale format=comma15., (select sum(Sales) from sashelp.shoes where Returns gt 100) as grandtot
  from sashelp.shoes
  where Returns gt 100
  group by Region
  order by Totsale
  ;
quit;

proc summary data=sashelp.shoes;
  title 'proc sql vs. datastep - datastep raw';
  class Region;
  var Sales;
  where Returns gt 100;
  output out=t sum=Totsale;
run;
proc print data=_LAST_(obs=max) width=minimum; run;


endsas;
 /* SAS really wins here: */

proc sql;
  title 'proc sql vs. datastep - sql raw';
  select Region, Product, sum(Sales) as Totsale format=comma15., (select sum(Sales) from sashelp.shoes where Returns gt 100) as grandtot
  from sashelp.shoes
  where Returns gt 100
  group by Region, Product
  order by Region, Product, Totsale
  ;
quit;
proc summary data=sashelp.shoes;
  title 'proc sql vs. datastep - datastep raw';
  class Region Product;
  var Sales;
  where Returns gt 100;
  output out=t sum=Totsale;
run;
proc print data=_LAST_(obs=max) width=minimum; run;
