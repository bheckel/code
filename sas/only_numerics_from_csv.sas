options NOcenter ps=max;

filename f 't2.csv';

data t;
  infile f DSD DLM=',' missover;
  input foo :$20. bar :$100. baz :$50.;
run;

data t;
  set t;

  var1=left(compress(upcase(bar),"ABCDEFGHIJKLMNOPQRSTUVWXYZ)(& -"));
  var2=left(compress(upcase(baz),"ABCDEFGHIJKLMNOPQRSTUVWXYZ)(& -"));

  if baz ne '' and baz ne 'OTHER';
run;
proc print data=_LAST_(obs=max) width=minimum; var var1 var2 bar baz; run;
