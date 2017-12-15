%global YEAR RECCOUNT;
%let YEAR=2004;
%let STABBR=NC;

%macro CountYrs;
  %do i=%eval(&YEAR-1) %to &YEAR ;
    libname L&i "/u/dwj2/register/NAT/&i";
    data tmp&i (keep=y rec_count);
      set L&i..register;
      if stabbrev eq "&STABBR";
      y="&i";
    run;
    proc append base=allcnt data=tmp&i;
    run;
  %end;
%mend;
%CountYrs;

proc print data=allcnt label; 
  format rec_count COMMA8.;
  label y = 'Year'
        rec_count = 'Count'
        ;
  var y rec_count;
run;
