
data _null_;
  do line = 9 to 10;
    left = 'Line-' || put(line,2.-L);
    right = 'Line-' || put(line,2.);
    put @2 left= / right=;
  end;
run;
