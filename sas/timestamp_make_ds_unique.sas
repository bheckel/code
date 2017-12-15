
%let tstamp=%sysfunc(compress(&SYSTIME, ':'));
proc datasets lib=DATA;
  change ccecallrequest=ccecallrequest_&tstamp;
  change final_to_insert=final_to_insert_&tstamp;
  change prev_ccepatientstaging=prev_ccepatientstaging_&tstamp;
  change tmm345=tmm345_&tstamp;
run;
