options ls=180;

data t;
  length bar $20;
  bar='one,two,three';
  output;
  bar='xwo2,xwo,xhree,,,';
  output;
  bar='zwo,zwo3,zhree,';
  output;
run;

data t;
  set t;
  r = reverse(trim(left(bar)));
  more = 'yes';
  do while (more eq 'yes');
    if r eq: ',' then 
      r = substr(r, 2);

    if r eq: ',' then 
      more = 'yes';
    else
      more = 'no';
  end;

  bar = reverse(r);
run;
proc print data=_LAST_(obs=max) width=minimum; run;
