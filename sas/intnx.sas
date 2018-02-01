options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: intnx.sas
  *
  *  Summary: Calculate the date in future or past given a range.
  *           Move in increments of months/days/yrs back/fwd from today.
  *
  *  Created: Tue 15 Jun 2010 09:48:48 (Bob Heckel)
  * Modified: Tue 23 Jan 2018 10:53:41 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source;

data _NULL_;
  past = intnx('year', '05jan2000'D, -4, 'S');
  future = intnx('year', '05jan2000'D, 4, 'S');
  put '01jan2000 ' past= DATE9.;
  put '01jan2000 ' future= DATE9.;

  /* Using the alignment parameter: */
  /* Beginning (same as default) */
  begpast = intnx('year', '01jan2000'D, -4, 'B');
  begfuture = intnx('year', '01jan2000'D, 4, 'B');
  put '01jan2000 ' begpast= DATE9.;
  put '01jan2000 ' begfuture= DATE9.;

  /* Middle of month */
  midpast = intnx('year', '01jan2000'D, -4, 'M');
  midfuture = intnx('year', '01jan2000'D, 4, 'M');
  put '01jan2000 ' midpast= DATE9.;
  put '01jan2000 ' midfuture= DATE9.;

  /* End */
  endpast = intnx('year', '01jan2000'D, -4, 'E');
  endfuture = intnx('year', '01jan2000'D, 4, 'E');
  put '01jan2000 ' endpast= DATE9.;
  put '01jan2000 ' endfuture= DATE9.;

  /* today() won't work */
  past = intnx('month', "&SYSDATE"D, -4);
  future = intnx('month', "&SYSDATE"D, 4);
  put "4 months ago from &SYSDATE " past= DATE9.;
  put "4 months from now &SYSDATE " future= DATE9. /;

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

  count=intck('day50','01oct1998'd, '01jan1999'd);  /* 1 */
  start=intnx('day50','01oct98'd,1);                /* prove only 1 interval crossed, on 14200 i.e. 17nov98 */

  put / 'months with 3 paydays';
  count=intck('week2','01jul98'D, '31jul98'D);
  put count=;
  count=intck('week2','01aug98'D, '31aug98'D);
  put count=;
  count=intck('week2','01sep98'D, '30sep98'D);
  put count= /;

  put / 'last Presidential election';
  count=intnx('year4.11', "&SYSDATE"D, 0);
  put count= DATE9.;
  put / 'next Presidential election';
  count=intnx('year4.11', "&SYSDATE"D, 1);
  put count= DATE9.;
run;
 

%macro m;
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



/* We want e.g. 2017-12-01 if the refresh that builds the 20180101 folder on the 16th hasn't happened yet this month */
%if  %sysfunc(day("&SYSDATE"d)) le 16 %then %do;
  %let bom=%sysfunc(intnx(month, "&SYSDATE"d, -1, b), yymmddN8.); %put A. &=bom;
%end;
%else %do;
  /* We want e.g. 2018-01-01 if the current refresh on 15th has happened this month */
  %let bom=%sysfunc(intnx(month, "&SYSDATE"d, 0, b), yymmddN8.); %put B. &=bom;
%end;
%mend;
/* %m; */
