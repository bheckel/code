 /* Every 5 days it's 0 */
%put !!! %sysfunc(mod((%sysfunc(today())-"09SEP2015"d),5));
