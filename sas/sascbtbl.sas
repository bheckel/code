
filename sascbtbl "t.dat";

data _null_;
  length path $200;
  n = modulen('*i', "KERNEL32,GetTempPathA", 199, path);
  put n= path=;
run;
