options noreplace;

data t;
  set sashelp.shoes end=e;
  if e then
    do;
      output;
      output;
    end;
  else
    output;
run;
