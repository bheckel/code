/*----------------------------------------------------------------------------
 *     Name: missover.sas
 *
 *  Summary: Demo of MISSOVER.  FLOWOVER is the default.
 *           See truncover.sas
 *
 * 
 * FLOWOVER
 * Causes an INPUT statement to continue to read the next input data record if it
 * does not find values in the current input line for all the variables in the
 * statement. This is the default! behavior of the INPUT statement. 
 * 
 * 
 * 
 * MISSOVER 
 * Prevents an INPUT statement from reading a new input data record if it does
 * not find values in the current input line for all the variables in the
 * statement. When an INPUT statement reaches the end of the current input data
 * record, variables without any values assigned are set to missing. 
 * 
 * Tip: Use MISSOVER if the last field(s) may be missing and you want SAS to
 * assign missing values to the corresponding variable. 
 * 
 *           MISSOVER only works for missing values that occur at the END of
 *           the record!
 * 
 * 
 * TRUNCOVER 
 * Overrides the default behavior of the INPUT statement when an input data
 * record is shorter than the INPUT statement expects. By default, the INPUT
 * statement automatically reads the next input data record. TRUNCOVER enables
 * you to read variable-length records when some records are shorter than the
 * INPUT statement expects. Variables without any values assigned are set to
 * missing. 
 * 
 * Tip: Use TRUNCOVER to assign the contents of the input buffer to a variable
 * when the field is shorter than expected. 
 * 
 * 
 * 
 * SCANOVER 
 * causes the INPUT statement to scan the input data records until the character
 * string that is specified in the @'character-string' expression is found.
 * Interaction: The MISSOVER, TRUNCOVER, and STOPOVER options change how the
 * INPUT statement behaves when it scans for the @'character-string' expression
 * and reaches the end of record. By default (FLOWOVER option), the INPUT
 * statement scans the next record while these other options cause scanning to
 * stop. 
 * 
 * Tip: It is redundant to specify both SCANOVER and FLOWOVER. 
 * 
 * 
 * 
 * STOPOVER 
 * causes the DATA step to stop processing if an INPUT statement reaches the end
 * of the current record without finding values for all variables in the
 * statement. When an input line does not contain the expected number of values,
 * SAS sets _ERROR_ to 1, stops building the data set as though a STOP statement
 * has executed, and prints the incomplete data line. 
 * 
 * Tip: Use FLOWOVER to reset the default behavior. 
 *
 *  Created: Wed 03 Jul 2002 15:35:57 (Bob Heckel)
 * Modified: Fri 18 Jun 2010 15:55:08 (Bob Heckel)
 *----------------------------------------------------------------------------
 */
options linesize=180 pagesize=32767 nodate source source2 notes mprint
        symbolgen mlogic obs=max errors=5 nostimer number serror merror
        noreplace;
title; footnote;

/* You'll get 'NOTE: SAS went to a new line when INPUT statement reached
 * past the end of a line' on these when not using MISSOVER
 */


 /* Without MISSOVER we don't have to worry about newlines */
data singlelines;
  input a $ b $ c d e;
  cards;
evans   donny 11229 996 63
fvans   eonny 11230
997 64
gvans   gonny 11231 998 65
  ;
run;
proc print; run;



data t;
/***  infile datalines;***/
  /* same */
/***  infile datalines FLOWOVER;***/
/***  infile datalines MISSOVER;***/
  /* same */
/***  infile datalines TRUNCOVER;***/
  /* Aborts */
  infile datalines STOPOVER;
  list;
  /* List input style. */
  input a b c;
  /* Line 3 is missing a value for var b. Line 5 missing a value for var c */
  datalines;
  770 2 9
  771 2 9
  772   9
  5390  2 9
  6475  2
  6475  2 9
  ;
run;
proc print data=_LAST_(obs=max) width=minimum; run;


