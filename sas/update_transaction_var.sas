/*----------------------------------------------------------------------------
 * Program Name: update_transaction_var.sas
 *
 *      Summary: Demo from SAS Programming of updating a ds with a transaction
 *               variable allowing specific vars to update.
 *
 *      Adapted: Tue Jul 13 1999 13:02:44 (Bob Heckel)
 *----------------------------------------------------------------------------
 */
options linesize=80 pagesize=32767 nodate source source2 notes mprint
        symbolgen mlogic obs=max errors=5 nostimer number serror merror
        noreplace;

title; footnote;

data work.todate;
  infile cards missover;
  input idnum tothrs totvac;
  cards;
1032 900.0 30.0
1071 400 0.0
1092 200.0 20.0
;
run;

data work.thisweek;
  infile cards missover;
  input idnum  type $  hours;
  cards;
1032 W 1.0
1071 V 2.0
1032 V 3.0
;
run;

proc sort data=work.thisweek; by idnum; run;

data work.todate(drop=type hours);
  update work.todate work.thisweek;
  by idnum;
  if type = 'W' then tothrs + hours;
  else if type = 'V' then totvac + hours;
run;

proc print data=work.todate; run;

/* Sample Output:
                                                                              37

                        OBS    IDNUM    TOTHRS    TOTVAC

                         1      1032      901       33
                         2      1071      400        2
                         3      1092      200       20
*/                         
