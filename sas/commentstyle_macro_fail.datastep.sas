
 /* See http://support.sas.com/kb/32/684.html for details */

data _null_;
  t=foo;
  ***if substr(key, 1, 1) ne ';';
  if substr(t, 1, 1) not in('', ' ', ';');
  call symput(T, compress(t));
run;

endsas;
Commented out line causes failure.
