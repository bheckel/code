
data t;
  infile cards;
  input (Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec) (1.);
  cards;
111222333444
222333444555
333444555666
  ;
run;
proc print data=_LAST_(obs=max) width=minimum; run;

 /* Convert months into four new summed quarter variables */
data t2(drop=Jan--Dec);
  set t;

  /*         R C           */
  array marr{4,3} Jan--Dec;
  array qarr{4};

  do i=1 to 4;  /* over 4 months */
    qarr{i}=0;
    do j=1 to 3;  /* over 3 quarters */
      qarr{i}+marr{i,j};  /* accumulator */
    end;
  end;
run;
proc print data=_LAST_(obs=max) width=minimum; run;
