/*----------------------------------------------------------------------------
 * Program Name: inout_wo_sas.sas
 *
 *      Summary: Copy records from the input file to an output file without
 *               creating any SAS variables.
 *
 *      Created: Thu Apr 29 1999 15:05:43 (Bob Heckel)
 *----------------------------------------------------------------------------
 */
options linesize=80 pagesize=32767 nodate source source2 notes mprint
        symbolgen mlogic obs=max errors=3 nostimer number serror merror;

title; footnote;

data _null_;
  infile 'my_processed.txt';
  file 'my_un_processed.txt';
  input;
  put _infile_;
run;  
