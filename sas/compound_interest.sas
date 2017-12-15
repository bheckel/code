 /* Compounded monthly */

 /* One year with no additions */
data t;
  amount = 1000;
  rate = 0.015/12;
  do i = 1 to 12;
    earned+((amount+earned)*rate);
    ***output;  /* watch it grow */
  end;
  put _all_;
run;
proc print data=_LAST_(obs=max) width=minimum; run;


 /* 20 years with additions */
data t;
  do yr=1 to 20;
    capital+2000;
    do mon=1 to 12;
      interest = capital+(0.075/12);
      capital+interest;
    end;
  end;
run;
proc print data=_LAST_(obs=max) width=minimum; run;
