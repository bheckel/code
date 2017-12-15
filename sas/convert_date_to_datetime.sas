
%let enddt=22-DEC-10;

data t;
  format maxts2 baselastrun DATETIME18.;
  label maxts2 = 'ENDDT of most recent weekly run'
        basefname = 'Weekly run filename'
        baselastrun = 'Most recent weekly run time'
        ;

  maxts2 = input("&enddt:00:00:00", DATETIME18.);
  basefname = "UTPUTFILE";
  baselastrun = datetime();
run;
proc print data=t(obs=max) width=minimum; run;    
