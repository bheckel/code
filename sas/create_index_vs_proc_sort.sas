options stimer;

data largefile;
  infile cards;
  input keyvar $  b;
  cards;
1 2
3 4
5 6
7 8
3 0
  ;
run;
/***proc sort; by keyvar; run;***/
proc sql; create index keyvar on largefile(keyvar); quit;

data keyfile;
  infile cards;
  input keyvar $;
  cards;
66
3
  ;
run;
/***proc sort; by keyvar; run;***/
proc sql; create index keyvar on keyfile(keyvar); quit;


data matched;
  merge largefile(in=large) keyfile(in=key);
  by keyvar;
run;
proc print data=_LAST_(obs=max); run;
