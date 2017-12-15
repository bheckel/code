options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: proc_univariate.sas
  *
  *  Summary: Statistics on a single variable
  *
  *  Created: Fri 18 Dec 2015 15:31:10 (Bob Heckel)
  * Modified: Fri 06 Jan 2017 14:10:51 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source NOcenter dsoptions=note2err mrecall;

/***ods select BasicMeasures ExtremeObs;***/
proc univariate data=sashelp.cars;
  var cylinders;
run;

title 'cyl';
ods graphics on;
proc univariate data=sashelp.cars NOprint;
  histogram cylinders / odstitle=title;
  inset n = '# cyl' / position=NE;
run;


endsas;
proc univariate data=sashelp.cars;
  var mpg_city;  /* continuous analysis variable */
  id make;  /* label in table of extreme observations */
  histogram mpg_city / normal (mu=est sigma=est);  /* sasgraph.png */
  inset skewness kurtosis / position=ne;  /* northeast corner */
  /* TOGGLE - this sasgraph.png overwrites the histogram */
  probplot mpg_city / normal (mu=est sigma=est);
run;


 /* SGPlot.png */
 /* Top/bot whisker is IQR * 1.5 */
 /* Top of box is 75th percentile */
 /* Horizontal line inside box is the median (50th percentile) */
 /* Bottom of box is 25th percentile */
 /* Diamond is mean */
proc sgplot data=sashelp.cars;
  refline 30 / axis=y lineattrs=(color=blue);
  vbox mpg_city / datalabel=make;
run;



title 't test 1';
 /* Generate just the t statistics */
ods select testsforlocation;

 /* We're expecting the true pop MPG to be 30, the test value of our null
  * hypothesis, H0.  Therefore our alternative hypothesis, Ha, is that the mu
  * (pop mean) is not equal to 30.
  */
proc univariate data=sashelp.cars mu0=30 alpha=.01;  /* .01 is the default */
  var mpg_city;  /* continuous analysis variable */
run;
 /*

Test           -Statistic-    -----p Value------

Student's t    t  -39.2547    Pr > |t|    <.0001

p-value < alpha .05 so reject null hypothesis, there IS a statistical difference 
between the sample mean and the hypothesized mean of 30

 */

title 't test 2';
proc univariate data=sashelp.cars mu0=20 alpha=.05;
  var mpg_city;
run;
 /*
Test           -Statistic-    -----p Value------

Student's t    t  0.239921    Pr > |t|    0.8105

p-value > alpha .05 so fail to reject null hypothesis, there is NOT a statistical difference 
between the sample mean and the hypothesized mean of 20.  There is not enough evidence
to say that the sample mean is statistically different from 20.
 */
