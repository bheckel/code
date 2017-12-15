libname L '/u/dwj2/register/NAT/2004';

data _null_;
  call symput('CREATEDFROM',attrc(open('L.register'), 'label'));
run;
%put &CREATEDFROM;
