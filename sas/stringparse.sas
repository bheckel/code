 /* If v9's perl regex with capturing parens is not available */
data skipmiddle;
  s='AM0895IMPHPLC{STD,CHEMMETHODS}.ANYUNSPECFPDEGRADIMP';
  len=length(s);
  p1=index(s, '{');
  p2=index(s, '}');
  one=substr(s, 1, p1-1);
  two=substr(s, p2+2);
  beforedot=scan(s, 1, '.');
  rev=reverse(substr(reverse(s), 4));  /* remove DIMP */
  put _all_;
run;
proc print data=_LAST_(obs=max) width=minimum; run;

data _null_;
  f='/home/bheckel/foo.txt';
  fbasenm = scan(f, -1, '/');
run;
