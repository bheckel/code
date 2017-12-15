%macro normality(input=, vars=, output=);
  %put !!!&input &vars;
  data _null_; file PRINT; put 78 * '~'; run;

  ods output TestsForNormality = Normal;
    proc univariate data = &input normal;
      var &vars;
    run;
  ods output close;

  data &output;
    set Normal (where = (Test = 'Shapiro-Wilk'));
    if pValue > 0.05 then Status ="Normal!!!";
    else Status = "Non-normal";
    drop TestLab Stat pType pSign; 
  run;
%mend;

title "&SYSDSN";proc print data=sashelp.cars(obs=10) width=minimum heading=H;run;title;

/***%normality(input=sashelp.cars, vars=Cylinders Horsepower, output=Normality);***/
%normality(input=sashelp.cars, vars=Cylinders, output=Normality);
