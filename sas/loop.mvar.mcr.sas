 /* see also ~/code/sas/loop_list_mvars.sas */
%let STR1=foo;
%let STR2=bar;
%let STR3=baz;

%macro l;
  %global STR;
  %do i=1 %to 3;
    %let STR=&STR &&STR&i;
  %end;
%mend;
%l

%put _all_;
