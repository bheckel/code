options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: intnx.sas
  *
  *  Summary: Calculate the date in future or past given a range.
  *           Move in increments of months/days/yrs back/fwd from today.
  *
  *  Created: Tue 15 Jun 2010 09:48:48 (Bob Heckel)
  * Modified: Tue 01 Mar 2016 16:03:23 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source;

data _NULL_;
  past = intnx('year', '01jan2000'D, -4);
  future = intnx('year', '01jan2000'D, 4);
  put past= DATE9.;
  put future= DATE9.;

  /* Using the alignment parameter: */
  /* Beginning (same as default) */
  past = intnx('year', '01jan2000'D, -4, 'B');
  future = intnx('year', '01jan2000'D, 4, 'B');
  put past= DATE9.;
  put future= DATE9.;

  /* Middle of month */
  past = intnx('year', '01jan2000'D, -4, 'M');
  future = intnx('year', '01jan2000'D, 4, 'M');
  put past= DATE9.;
  put future= DATE9.;

  /* End */
  past = intnx('year', '01jan2000'D, -4, 'E');
  future = intnx('year', '01jan2000'D, 4, 'E');
  put past= DATE9.;
  put future= DATE9.;

  /* today() won't work */
  past = intnx('month', "&SYSDATE"D, -4);
  future = intnx('month', "&SYSDATE"D, 4);
  put past= DATE9.;
  put future= DATE9.;

  /* Sunday */
  startofweek = intnx('week', "&SYSDATE"D, 0, 'B');
  put startofweek = DATE9.;

  /* Multiplier - 2 month periods */
  /* January–February, March–April, May–June, July–August, September–October, November–December */
  firstdayofmonthpairs = intnx('MONTH2', '01jan2016'd, 0);
  put firstdayofmonthpairs= DATE9.;
  firstdayofmonthpairs = intnx('MONTH2', '01jan2016'd, 1);
  put firstdayofmonthpairs= DATE9.;
  firstdayofmonthpairs = intnx('MONTH2', '01jan2016'd, 2);
  put firstdayofmonthpairs= DATE9.;

  /* Multiplier & shift index - 2 month periods starting on second month of year */
  /* December–January of the following year, February–March, April–May, June–July, August–September, October–November */
  firstofmopairs_offsetto2ndmo = intnx('MONTH2.2', '01jan2016'd, 0);
  put firstofmopairs_offsetto2ndmo= DATE9.;
  firstofmopairs_offsetto2ndmo = intnx('MONTH2.2', '01jan2016'd, 1);
  put firstofmopairs_offsetto2ndmo= DATE9.;
  firstofmopairs_offsetto2ndmo = intnx('MONTH2.2', '01jan2016'd, 2);
  put firstofmopairs_offsetto2ndmo= DATE9.;
run;
 


/* We want either a 2 month pull or a pull from Jan 1 of current year, whichever is larger */
%let thismo = %sysfunc(month("&SYSDATE"d));

%if &thismo le 2 %then %do;
  /* Use 60 days ago */
  %let date_exec2 = %sysfunc(putn(%sysevalf("&date_exec"d -60),DATE9.));
%end;
%else %do;
  /* Use Jan 1 */
  %let date_exec2=%sysfunc(intnx(year, "&date_exec"d, 0, B), DATE9.);
%end;
%put &=thismo &=date_exec &=date_exec2;
