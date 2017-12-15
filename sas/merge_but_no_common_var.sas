
data cars;
  input lastname :$15. typeofcar :$15. mileage;
  datalines;
Jones Toyota 7435
Smith Toyota 13001
Jones2 Ford 3433
Smith2 Toyota 15032
Shepherd Nissan 4300
Shepherd2 Honda 5582
Williams Ford 10532
  ;
run;

data schedmaint;
  input startrange endrange typeofservice $35.;
  datalines;
3000 5000 oil change
5001 6000 overdue oil change
6001 8000 oil change and tire rotation
8001 9000 overdue oil change
9001 11000 oil change
11001 12000 overdue oil change
12001 14000 oil change and tire rotation
14001 14999 overdue oil change
15000 15999 15000 mile check
  ;
run;

/* Iterate a dataset inside a data step:
 *
 * Read the first observation from the SAS data set outside the DO loop.
 *
 * Start the DO loop reading observations from the SAS data set inside the DO 
 * loop. 
 *
 * Process the IF condition; if the IF condition is true, OUTPUT the 
 * observation and set the FOUND variable to 1.  
 *
 * Go back to the top of the DATA step and read the next observation from the
 * data set outside the DO loop and process through the DATA step again
 * until all observations from the data set outside the DO loop have been
 * read. 
 */
data combine;
  set cars;
  found=0;
  do i=1 to nobs until (found);
    set schedmaint point=i nobs=nobs;
    if startrange <= mileage <= endrange then do;
      output;
      found=1;
    end;
  end;
run;
title 'recommended service'; proc print data=_LAST_(obs=max) width=minimum; run;
