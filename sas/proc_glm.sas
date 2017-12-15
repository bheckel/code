title "&SYSDSN";proc print data=sashelp.cars(obs=10) width=minimum heading=H;run;title; data;file PRINT;put '~~~~~~~~~~~~~~~~~~~~~~';put;run;

proc glm data=sashelp.cars(where=(make in('Acura','Audi'))) plots(only)=diagnostic(unpack);
  class horsepower;
  model mpg_city=horsepower;
  /* Mean for each hp level */
  means horsepower / hovtest;
run;
quit;
