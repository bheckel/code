options NOcenter;

%macro ForEach(s);
  %local i f;

  %let i=1;
  %let f=%scan(&s, &i, ' '); 

  %do %while ( &f ne  );
    %let i=%eval(&i+1);
    /*..............................................................*/
    libname REG "/u/dwj2/register/&f/2004";
    data REG.history;
      set REG.history;
      /*** PROCESSED_BY='        '; ***/
      REVTYPE = '   ';
    run;
    /*** proc print data=_LAST_; run; ***/
    proc contents; run;
    /*..............................................................*/
    %let f=%scan(&s, &i, ' '); 
  %end;
%mend ForEach;
%ForEach(NAT MOR FET MED MIC)
