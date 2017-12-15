
filename here '.';
%let pwd=%sysfunc(pathname(here)); 

endsas;
 /* inferior version */
filename P PIPE 'cd';

data _null_;
  infile P;
  input;
  call symput('PWD', _infile_);
run;
%put _all_;
