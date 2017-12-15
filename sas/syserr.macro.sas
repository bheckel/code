
%macro m;
  data f;
    infile F 'doesntexist';
  run;

  %if &SYSERR eq 0 %then
    %do;
      proc print data=sashelp.shoes(obs=max); run;
    %end;
  %mend;
%m
