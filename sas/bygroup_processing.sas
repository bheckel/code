options nosource;
 /*----------------------------------------------------------------------------
  *     Name: bygroup_processing.sas
  *
  *  Summary: Process by groups
  *
  *           See also sql_groupby.sas, firstdot.sas
  *
  *  Created: Thu Jun 03 1999 16:18:52 (Bob Heckel)
  * Modified: Fri 29 Jul 2016 09:03:26 (Bob Heckel)
  *----------------------------------------------------------------------------
  */
options linesize=80 pagesize=32767 nodate source source2 notes mprint
        symbolgen mlogic obs=max errors=5 nostimer number serror merror
        noreplace;

 /* Simple but useless */
data t;
  set sashelp.shoes;
  by region;
  if last.region;
run;
proc print data=_LAST_(obs=max) width=minimum; run;



title 'Unordered data to keep months in human order';
data sample;
   input density  crimerate  mo $ 14-21;
   cards;
264.3 3163.2 January
51.2 4615.8  January
55.2 4271.2  February
9.1 2678.0   February
102.4 3371.7 February
9.4 2833.0   March
120.4 4649.9 April
  ;
run;
proc print; run;

title 'Data processed while keeping months in human order';
data calendar_month_order;
  set sample;
  /* mo is not sorted alpha, it is sorted by calendar (the way we want it) */
  by mo NOTSORTED;
  tot+density;
  if last.mo;
run;
proc print; run;



 /* Sum groups http://support.sas.com/documentation/cdl/en/lrcon/67885/HTML/default/viewer.htm#p0e9b2d12lpyjkn1b0y1tqg6q146.htm */
data salaries;    
   input department $ name $ WageCategory $ WageRate;    
   datalines; 
BAD Carol Salaried 2000 
BAD Elizabeth Salaried 5000 
BAD Linda Salaried 7000 
DDG Jason Hourly 200 
DDG Paul Salaried 4000 
PPD Kevin Salaried 5500 
PPD Amber Hourly 150 
PPD Tina Salaried 13000 
STD Jim Salaried 8000
; 
run;
proc print data=salaries; run;
proc sort data=salaries out=temp; by department; run;

data budget(keep=department Payroll);   
   set temp;       
   by department; 

   if WageCategory='Salaried' then YearlyWage=WageRate*12;    
   else if WageCategory='Hourly' then YearlyWage=WageRate*2000;  

   /* SAS sets FIRST.variable to 1 if this is a new        */
   /* department in the BY group.                          */
   if first.department then Payroll=0;    

   Payroll+YearlyWage;

   /* SAS sets LAST.variable to 1 if this is the last      */
   /* department in the current BY group.                  */
/***   if last.department then output; ***/
   /* same */
   if last.department; 
run;

proc print data=budget;    
   format Payroll dollar10.;
   title 'Annual Payroll by Department'; 
run;
