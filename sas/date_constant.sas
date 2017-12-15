 /*---------------------------------------------------------------------------
  *     Name: date_constant.sas
  *
  *  Summary: Demo of using a date and datetime and time constants for
  *           comparison.
  *
  *           CAUTION: do not compare a datetime datatype with e.g. '01AUG05'd
  *                    instead must use '01AUG05:00:00:00'dt
  *
  *  Adapted: Thu 11 Apr 2002 14:41:23 (Bob Heckel -- Little SAS Book sect 3.7)
  * Modified: Mon 25 Aug 2008 14:21:31 (Bob Heckel)
  *---------------------------------------------------------------------------
  */

data work.librarycards;
  infile cards TRUNCOVER;
  input name $11. +1 birthdate DATE9. +1 issuedate MMDDYY10.;

  expiredate = issuedate + (365.25 * 3);
  expirequarter = qtr(expiredate);

  /* Date constant must be 'DDMMMYY'd or 'DDMMMYYYY'd */
  if issuedate > '01jan1999'D then newcard = 'yes';
  cards;
A. Jones    1jan60    9-15-95
M. Rincon   05OCT1949 01-24-1997
Z. Grandage 18mar1988 10-10-1999
K. Kaminaka 29may1996 02-29-2000
  ;
run;


proc print;
  * birthdate will be 0, -3740, 10304 and 13298 b/c it's not formatted.;
  format issuedate MMDDYY8. expiredate WEEKDATE17.;
  title 'SAS Dates with and without Formats';
run;


 /************** Unrelated to previous code  **************/
 /* Demo of SAS date datetime and time constants. */
data _NULL_;
  /* Character date */
  date0 = "&SYSDATE";
  /* Make it numeric. */
  date1 = "&SYSDATE"D;
  /* Same as date1 */
  date2 = date();
  date3=put(date2, YYMMDD10.);
  datetime1 = "07JUL00:11:02:00"DT;
  time1 = "00:02:00"T;
  put "To the Log: &SYSDATE &SYSTIME";
  put _ALL_;
run;
