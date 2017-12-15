
options ls=180;
data t(rename=(Nresult=result));
  set l.serevent60_analytic_individuals(rename=(result=Sresult));

  isnum = verify(compress(Sresult), '.0123456789');

  if isnum eq 0 then
    Nresult = input(Sresult, F8.);
  else
    Nresult = .;
run;

proc format;
  value f_bob LOW -< 1  = 'one'
            2 -< 3  = 'two'
            4 - HIGH  = 'oth'
  ;
run;

proc freq data=t;
  format result f_bob.;
  tables result;
run;
