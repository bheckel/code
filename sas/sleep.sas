 /* Simple 10 seconds */
data _null_;
  x=sleep(10);
run;


 /* Execute at specific time */
data budget;    
  sleeptime='26aug2008:14:06'dt-datetime(); 
  time_calc=sleep(sleeptime, 1);
run;


endsas;
 /* Build yer own */
data _null_;
   put "NOTE: Sleeping 10 seconds...";
   t = time();
   do while (time()-t < 10); 
     /* sleep */
   end;
   put '...done';
run;

