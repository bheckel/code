options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: proc_reg.sas
  *
  *  Summary: Demo of linear regression
  *
  *  Adapted: Tue 13 Sep 2016 14:23:10 (Bob Heckel--http://www.ats.ucla.edu/stat/sas/webbooks/reg/chapter1/sasreg1.htm)
  *---------------------------------------------------------------------------
  */
options source NOcenter dsoptions=note2err;

title 'Average class size, is not significant, but only just so, and the coefficient is negative which would indicate that larger class sizes is related to lower academic performance.';

title2 'Meals is significant and its coefficient is negative indicating that the greater the proportion students receiving free meals, the lower the academic performance.';

title3 'Percentage of teachers with full credentials seems to be unrelated to academic performance. This would seem to indicate that the percentage of teachers with full credentials is 
not an important factor in predicting academic performance.';

title4 'The R-squared is 0.6745, meaning that approximately 67% of the variability of api00 is accounted for by the variables in the model';

proc reg data='./elemapi';
  /* api = academic performance of the school 200-1000 */
  model api00 = acs_k3 meals full;
run;


title 'Examine all data';

proc print data='./elemapi'(obs=10) width=minimum heading=H;run;title;

proc contents data='./elemapi'; run;

proc means  data='./elemapi';
  var api00 acs_k3 meals full;
run;


title 'avg class size seems odd so investigate specific data';
/* ./sasgraph.png */
proc univariate data='./elemapi';
  var acs_k3;
  histogram / cfill=gray;
run;

proc univariate data='./elemapi' plot;
  var acs_k3;
run;


title 'correlation English learners & Free meals';
proc corr data='./elemapi';
/***  var api00 ell meals yr_rnd mobility acs_k3 acs_46 full emer enroll ;***/
  var api00 meals ell;
run;
