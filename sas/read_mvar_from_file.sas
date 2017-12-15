options NOsgen;
%let F = %sysget(TMP);  /* OS environment variable */

filename F "&F/junk";

data _null_;
  infile F TRUNCOVER;
  input x $9500.;
  n+1;
  call symput('M'||compress(n), x);
run;
%put &M2;

endsas;
data _null_;
  infile F TRUNCOVER;
  /* Assuming a single, possibly long, line */
  input x $9500.;
  call symput('M', x);
run;
%put &M;
