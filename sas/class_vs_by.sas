data Cars;
   set Sashelp.Cars;
   where cylinders in (4,6,8) and type ^= 'Hybrid'; 
run;
 
proc sort data=Cars out=CarsSorted; 
   by Origin; 
run;


title '--------CLASS--------';
title2 'Use a CLASS statement when you want to compare or contrast groups';
proc means data=Cars N Mean Std;
   class Origin;  /* categorical */
   var Horsepower Weight Mpg_Highway;
run;


title '--------BY--------';
title2 'Use a BY statement in SAS procedures when you want to repeat an analysis for every level of one or more categorical variables.';
title3 'The variables define the subsets but are not otherwise part of the analysis.';
proc means data=CarsSorted N Mean Std;
   by Origin;  /* categorical */
   var Horsepower Weight Mpg_Highway;
run;


title 'compare with freq';
proc freq; table Origin; run;
