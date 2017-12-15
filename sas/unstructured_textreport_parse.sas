
data t;
  filename F 't.txt';
  infile F MISSOVER;
  input @'batch' bch $CHAR9.;
run;
proc print data=_LAST_(obs=max) width=minimum; run;

endsas;
t.txt:
foo bar   unstructured

more things [here]
 
                      and over here
    batch: 9zm1234

eot
