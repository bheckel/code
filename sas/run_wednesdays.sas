
%let DIRROOT = \\rtpsawnv0312\pucc\ADVAIR_HFA;
%let CODE = &DIRROOT\CODE;

data _null_;
  if weekday(today()) eq 4 then do;
    put 'stability job temporily suspended';
    call execute('%include "&CODE\PLOT_CODE\plotting_ADVAIR_analytical_trends.sas";');
    call execute('%include "&CODE\PLOT_CODE\plotting_ADVAIR_scatterplots.sas";');
  end;
run;
