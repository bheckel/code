
data iso;
  input @1 isodate e8601dz27.1 ;
  put isodate= isodate= datetime27.1 isodate=e8601dz27.1;
  datalines;
2013-04-27T18:00:00,1-05:00
2013-04-27T23:00:00,1Z
2013-04-27T00:00:00.1Z
;;
run;
