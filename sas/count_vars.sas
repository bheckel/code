
data _NULL_;
  set sashelp.shoes(obs=1) NOBS=obscnt;

  array cc{*} $ _CHARACTER_;
  array nn{*} _NUMERIC_;

  varscnt=dim(cc)+dim(nn);

  call symput('NUMVARS', left(trim(varscnt)));
  call symput('NUMOBS', left(trim(obscnt)));
  stop;
run;

%put _all_;
