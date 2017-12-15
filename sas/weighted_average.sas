
data size;
   input Weighty ObjectSize @@;
   datalines;
 5 12   7  11   9 10   20 9
 50 8
;
run;
proc print data=_LAST_(obs=max) width=minimum; run;


title 'unweighted';
proc means data=size maxdec=3 n mean var stddev;
  var objectsize;
run;
proc print data=_LAST_(obs=max) width=minimum; run;


title 'weighted';
proc means data=size maxdec=3 n mean var stddev;
  weight Weighty;
  var objectsize;
  output out=wtstats;
run;
proc print data=_LAST_(obs=max) width=minimum; run;



 /* unrelated - weighted avg by batch and material groups */

/* Calc weighted averages */
proc means data=tmp mean NOprint;
  class Batch;
  weight Quantity;
  var Bulk_Density_gmL_50_tamps;
  id Material_Number;
  output out=tmp2;
run;
