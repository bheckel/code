
data t;
  input id x1-x5;
  cards;
1 . 89 85 . 87
2 79 73 74 . .
3 80 95 . 95 .
  ;
run;

data t2;
  set t;
  first = coalesce(of x1-x5);
  last = coalesce(of x5-x1);
run;
proc print noobs; run;
/*
id    x1    x2    x3    x4    x5    first    last

 1      .    89    85     .    87      89      87 
 2     79    73    74     .     .      79      74 
 3     80    95     .    95     .      80      95 
*/


 /* Extract the second non-missing value */
data out;
  set t;

  array value x1-x5;
  array nvalue(5) _temporary_;

  first = coalesce(of value(*));
  index = whichn(first, of value(*));

  do i = 1 to dim(value);
    if i = index then nvalue(i) = .;
    else nvalue(i)= value(i);
  end;

  drop i index;
  second = coalesce(of nvalue(*));
run;
proc print noobs; run;
