
data _null_;
  file "c:\temp\sample1727.txt";

  put "2005,2006,2007,Total Revenue";
  put "1,2,3,25000";
  put "4,5,6,50000";
run;

 /* Read first line into dataset */
data t;
  infile "c:\temp\sample1727.txt" dsd obs=1;
  input var1 :$4. var2 :$4. var3 :$4. var4 :$13.;
run;
proc print data=_LAST_(obs=max); run;
