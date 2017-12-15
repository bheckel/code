options serror;

 /* Almost always want to know about unresolved mvars... */
data _null_;
  x=1;
  y=2;
  buyer='foo';
  if x&y then do; end;
  if buyer="Smith&Jones, Inc." then do; end;
run;


options NOserror;

 /* ...but not here */
data _null_;
  x=1;
  y=2;
  buyer='foo';
  if x&y then do; end;
  if buyer="Smith&Jones, Inc." then do; end;
run;

