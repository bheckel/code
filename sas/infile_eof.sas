
 /* Do something at the end of reading an unbuffered text file */
data t;
  infile 'c:\cygwin\home\rsh86800\bladerun_crawl' eof=IMDONE;
  input @1 foo $80.;
  n+1;
  return;
IMDONE:
  put 'really: ' n=;
  stop;
run;
proc print data=_LAST_(obs=max) width=minimum; run;

