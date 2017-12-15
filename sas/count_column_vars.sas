options NOreplace;

libname L 'X:/BPMS/VA/Data/Providers/SAS';

 /* Convert character to numeric */
data tmp;
  set L.prescriber_validation;
  numer=input(medicaid_prescriber_id, F8.);
run;

proc sql;
  select sum(numer) as columncount
  from tmp
  ;
quit;


endsas;
 /* doesn't do what I thought */
proc sort data=L.prescriber_validation out=srtd;
  by medicaid_prescriber_id;
run;
proc summary data=srtd PRINT;
  by medicaid_prescriber_id;
  class medicaid_prescriber_id;
run;
