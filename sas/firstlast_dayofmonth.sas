
data _null_; 
   strt_dt = intnx('month', today(), 0, 'B'); 
   end_dt  = intnx('month', today(), 0, 'E'); 
   call symput('strt_dt',put(strt_dt, DATE9.)); 
   call symput('end_dt', put(end_dt, DATE9.)); 
run; 

%put !!!first day of month: &strt_dt  last day of month: &end_dt; 
