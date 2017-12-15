  data _NULL_;
    /* Macros accept globals instead of parameters due to potentially long query strings */
    set conqry;
    %let i=1;
    %do %until (%qscan(&vnms, &i)=  );
      %let f=%qscan(&vnms, &i);
        call symput("&f",left(trim(&f)));
      %let i=%eval(&i+1);
    %end;
    s1='%'||connectionID;
    call execute(s1);  /* 2010-08-06 SAS v8.2 unable to suppress incorrect SAS Log WARNING 32-169 */
  run;
