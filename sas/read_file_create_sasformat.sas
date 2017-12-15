options ls=180;

filename f "&HOME/tmp/t.txt";

data commadelimited;
  infile f DLM=',' DSD MISSOVER;
  input foo  nm :$80.  yn :$1.;
run;
proc print data=_LAST_(obs=max); run;


data ctrl (rename=(foo=START nm=LABEL));
   set commadelimited end=e;
   /*  Mandatory to name the format here */
   retain fmtname 'f_pts';
run;
 	

 /* Use the dataset to build the temporary format */
proc format library=work cntlin=ctrl; run;

 /* Now test format */
data sales;
  input acctnum;
  cards;
1
0
225
3
  ;
run;
proc print data=_LAST_(obs=max); 
  format acctnum f_pts.;
run;


endsas;
t.txt:
1,bottle,y
2,blister,y
3,other,n
