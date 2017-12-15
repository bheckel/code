options NOmlogic NOsgen;

%macro rnd;
  %do i=1 %to 10;
    %let x = %sysfunc(ranuni(0));
    %put %sysevalf(&x*10);
  %end;
%mend;
%rnd;
