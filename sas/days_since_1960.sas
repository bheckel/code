 /*---------------------------------------------------------------------------
  *      Name: days_since_1960.sas
  *
  *   Summary: Accepts SAS numeric date and returns days since 1/1/60, 
  *            SAS's epoch.
  *
  *            Convert date from numbers to SAS date.
  *
  *            To go from date to SAS number, see ~/bin/sasdate
  *
  *            TODO turn into macro that accepts parameter
  *
  *   Created: Thu 10/08/98 02:23:10 (Bob Heckel)
  *  Modified: Tue Jun 04 09:38:47 2002 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
option linesize=80 pagesize=32767 nodate source source2 notes mprint
       symbolgen mlogic obs=max errors=3 nostimer number;

* Returns 12/22/1959;
***%let numeric_date = -10;

* Returns 02/23/2001;
***%let numeric_date = 15029;
***%let numeric_date = -14623;
%let numeric_date = 16783;

data _NULL_;
  call symput('yr', put(year(&numeric_date),4.));
  call symput('mon', put(month(&numeric_date),z2.));
  call symput('day', put(day(&numeric_date),z2.));
run;

%put Converted date: &mon/&day/&yr;
