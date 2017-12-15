%macro m;
  /* Run every other Wednesday */

  %let mod=%sysfunc(mod((%sysfunc(today())-"08MAR2017"d),14));
  /* %let mod=%sysfunc(mod(('08MAR2017'd-"08MAR2017"d),14)); */
  /* %let mod=%sysfunc(mod(('22MAR2017'd-"08MAR2017"d),14)); */

  /* %let mod=%sysfunc(mod((%sysfunc(today())-"15MAR2017"d),14)); */
  /* %let mod=%sysfunc(mod(('15MAR2017'd-"15MAR2017"d),14)); */
  /* %let mod=%sysfunc(mod(('16MAR2017'd-"15MAR2017"d),14)); */

  %if &mod eq 0 %then %do;
    %put running;
  %end;
  %else %do;
    %put not running;
  %end;
%mend;
%m;

