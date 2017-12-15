
libname L 'c:/cygwin/home/bqh0/tmp/testing/bobb';

%macro WaitForLib(fqdsn);
  %local secs;
  %local maxcycles;

  %let secs=15;
  %let maxcycles=3;

  %if %sysfunc(exist(&fqdsn)) %then
    %do;
      %put NOTE: Dataset &fqdsn exists at &SYSDATE &SYSTIME;
    %end;
   %else 
     %do;
       data _NULL_;
         do i=1 to &maxcycles;
           put "WARNING: Data set &fqdsn does not exist at &SYSDATE &SYSTIME.";
           put "NOTE: Sleeping &secs seconds and trying again...";
           t = time();
           do while (time()-t < &secs); 
             /* sleep */
           end;
           put "NOTE: Wait cycle " i "completed";
           if exist("&fqdsn") then
             do;
               put "NOTE: &fqdsn is now available at &SYSDATE &SYSTIME";
               i=&maxcycles;
             end;
         end;
       run;
     %end;
%mend WaitForLib;
%WaitForLib(L.charity1);

