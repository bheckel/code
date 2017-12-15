 /*
x=2012-04-26
y=10:45:28
y2=10:45:28-04:00
y3=10:45:28+00:00
z=2012-04-26
z2=2012-04-26T10:45:28
z3=2012-04-26T10:45:28+00:00
 */
data _NULL_;
  x=put(date(), IS8601DA.);
  put x=;

  y=put(time(), IS8601TM.);
  put y=;
  y2=put(time(), IS8601LZ.);
  put y2=;
  y3=put(time(), IS8601TZ.);
  put y3=;

  z=put(datetime(), IS8601DN.);
  put z=;
  z2=put(datetime(), IS8601DT.);
  put z2=;
  z3=put(datetime(), IS8601DZ.);
  put z3=;
run;


