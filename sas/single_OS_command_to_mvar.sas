
filename getuid PIPE 'whoami';
data linuxorcygwin;
  infile getuid lrecl=20 PAD;
  input uid $20.;
run;

proc sql NOprint;
  select uid into :myID from linuxorcygwin;
quit;
%put !!! &myID;
