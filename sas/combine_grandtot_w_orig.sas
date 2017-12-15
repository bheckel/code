 /*---------------------------------------------------------------------------
  *     Name: combine_grandtot_w_orig.sas
  *
  *  Summary: Demo of combining a grand total back into the original data.
  *
  *  Adapted: Thu 11 Apr 2002 14:41:23 (Bob Heckel -- Little SAS Book sect 5.7)
  * Modified: Thu 09 May 2013 14:13:21 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options linesize=82 pagesize=32767 nodate source source2 notes mprint
        symbolgen mlogic obs=max errors=5 nostimer number serror merror
        noreplace datastmtchk=allkeywords;


/********/
/* Basic grand total: */
proc sql;
/***  select sum(actual) as act, sum(predict) as predict, sum(sum(actual), sum(predict)) as gtot***/
  /* same */
  select sum(actual) as act, sum(predict) as predict, sum(CALCULATED act, CALCULATED predict) as gtot
  from sashelp.prdsal2
  ;
quit;

/********/

data videos;
  input Title $ 1-29 ExerciseType $ Sales;
  cards;
Adorable Absolute Vodka       aerobics 1930
Aerobic Children for Parents  aerobics 2250
Judy Murphy's Funk Fitness    step     4150
Lavonnes' Lowly Workout       aerobics 1130
The Middle SAS Chicks Dieting weights  2230
Rock N Roll Step Passout      step     1190
  ;
run;


/* Dataset to be created here will contain a single obs containing a variable
 * named GrandTotal which is equal to the sum of Sales.
 */
proc summary data=videos;
 /* Same */
***proc means NOPRINT data=videos;
  var Sales;
  output OUT=work.summaryds sum(Sales) = GrandTotal;
run;
proc print data=summaryds;
  title 'The single observation proc summary dataset';
run;

title 'Compare with manual total';
data manualsummaryds;
  /* For pedantic reasons we're not using an accumlator approach.  So a RETAIN
   * with initialization is required otherwise all grandtot are '.' 
   */
  retain grandtot 0;   /* note: no equal sign! */
  /* Optional */
  format grandtot COMMA10.;
  set videos;
  /* "Sum statement with accumulator variable" does NOT require a RETAIN 0
   * like grandtot does. 
   */
  uselessObsCnt+1;
  grandtot = grandtot + Sales;
run;
proc print; run;


 /* Combine the grand total with the original data. */
data videosummary;
  /* Get the single value GrandTotal.  It is used throughout the datastep. */
  if _N_ = 1 then 
    set summaryds;
  set videos;
  Percent = Sales / GrandTotal * 100;
run;
proc print data = videosummary;
  var Title ExerciseType Sales GrandTotal Percent;
  title 'Overall Sales Share';
run;
