
 /* Date convert 22FEB2016 to 20160222 in macro: */
%put %sysfunc(putn(%sysfunc(inputn(&SYSDATE, DATE9.)), YYMMDDN8.));



 /* 2129 */
%put %sysfunc(putn('30OCT1965'D, 8.));

 /* 08JUN2007 */
%put %sysfunc(putn(17325, DATE9.));

 /* 02MAR12:00:30 */
%put %sysfunc(putn(1646267405, DATETIME14.));

 /* 20362 */
%put %sysfunc(inputn(20151001, YYMMDD8.));



%let date = '1-1-2014'; 
/* Strip away the single quotes */
%let deQuotedDate = %sysfunc(compress(&date., "'"));
%put &deQuotedDate.;
/* Read in the date using ddmmyy. informat and convert to SAS date */
%let sasDate = %sysfunc(inputn(&deQuotedDate., ddmmyy10.));
%put &sasDate.;
/* Convert the SAS date to the required format */
%let longDate = %sysfunc(putn(&sasDate., weekdate32.));
%put &longDate.;



 /* Postgres */
 /* '2015-10-01' */
%put %bquote(')%sysfunc(putn(%sysfunc(inputn(20151001, YYMMDD8.)), YYMMDD10.))%bquote(');

 /* '2015-10-01' */
%let date = 20151001; 
/* Read in the date using ddmmyy. informat and convert to SAS date */
%let sasDate = %sysfunc(inputn(&date, yymmdd8.));
%put &sasDate;
/* Convert the SAS date to the required format */
%let longDate = %sysfunc(putn(&sasDate, yymmdd10.));
%put %bquote(')&longDate.%bquote(');



data _null_;
  tuesday = intnx('week', "&SYSDATE"D, 0, 'B')-5;
  call symput('TUESDAY', put(tuesday, YYMMDDN8.));
  call symput('TUESDAY2', put(tuesday, YYMMDDD10.));
run;
