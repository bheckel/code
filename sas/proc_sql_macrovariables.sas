
proc sql noprint;
  SELECT left(trim(put(count(DISTINCT region),15.))) INTO :varCount
  FROM SASHELP.shoes
  ;
  SELECT DISTINCT region INTO :varVal1-:varVal&varCount
  FROM SASHELP.shoes
  ;
quit;
%put _all_;
