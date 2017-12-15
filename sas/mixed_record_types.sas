/*----------------------------------------------------------------------------
 * Program Name: mixed_record_types.sas
 *
 *      Summary: Read a file (use cards) with mixed record types.  Use
 *      trailing @ sign.
 *
 *      Created: Tue Apr 20 1999 14:12:26 (Bob Heckel)
 *----------------------------------------------------------------------------
 */
options linesize=80 pagesize=32767 nodate source source2 notes mprint
        symbolgen mlogic obs=max errors=3 nostimer number serror merror;

title; footnote;

/* Trailing @ line-hold specifier can be used to:
 * 1.  Hold current data line in the input buffer for another INPUT statement
 * to process it.
 * 2. Hold the column pointer at its present location in that data line.
 */
data work.sales;
  /*                                  Hold the current line
   *                                  while checking 'location'
   */
  input invoice $ 1-4  location $ 6-8 @;
  if location='USA' then
    input @10 date mmddyy8. @19 amount comma8.;
  else if location='EUR' then
    input @10 date date7. @18 amount commax8.;
  cards;
1012 USA  1-29-60 3,295.50
1013 USA  1-30-60 2,938.00
3034 EUR 30JAN60 1.876,44
1014 USA  2-5-60 2,023.71
3036 EUR 6FEB90 3.015,33
;
run;

proc print; run;

proc print;
  format date date7.;
  var location date;
run;
