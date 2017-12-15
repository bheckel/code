 /* http://www.excursive.com/sas/weblog/archive/2007_01_01_index.html */
options ps=max ls=180 NOcenter;

options nocodegen;  /* MANDATORY for this code */

 /* This program calculates the number days after a discharge date that a patient was taking a drug */

data patients;
   input @1  patient_id 2.
         @4  discharge_da date9.;
   format discharge_da date9.;
cards;
1  01feb2001
2  01jun2001
3  31dec2001
;;;;
run;
proc print data=_LAST_(obs=max) width=minimum; run;

data drugs;
   input @1  patient_id 2.
         @4  fill_da date9.
         @14 rx_days 3.;
   format fill_da date9.;
cards;
1  01mar2001 31
1  05feb2001 90
1  01jun2001 90
2  01jan2001 90
2  01jun2001 90
2  01dec2001 90
;;;;;
run;
proc print data=_LAST_(obs=max) width=minimum; run;

 /* Setup array daysbefore1-720 (seems unnecessary to use macro) */
%global DAYSBEFORE;
data _null_;
   length daysbefore $10000;
   daysbefore = ' ';
   do i = 720 to 1 by -1;
      daysbefore = trim(daysbefore) || ' daybefore' || put(i, 3.-L);
   end;
   call symput('DAYSBEFORE', daysbefore);
run; 
   
data info;
   merge patients drugs (in=in_drugs);
      by patient_id;

   array drug_days{-720:720} &DAYSBEFORE day0 daysafter1-daysafter720;
   retain &DAYSBEFORE day0 daysafter1-daysafter720;

   if first.patient_id then 
      do day = -720 to 720;
         drug_days{day} = 0;
      end;

   if in_drugs then 
      do day = (fill_da - discharge_da) to (fill_da - discharge_da + rx_days - 1);
         drug_days{day} = 1;
      end;

   if last.patient_id then 
      do;
        days0_through_30 = sum(0, day0, of daysafter1-daysafter30);
        days31_through90 = sum(0, of daysafter31-daysafter90);
        output;
      end;

/***   keep patient_id discharge_da days0_through_30 days31_through90;***/

run;
proc print data=_LAST_(obs=max) width=minimum; run;

proc report data=info nowindows split='/';
   columns patient_id discharge_da days0_through_30 days31_through90;
   define  patient_id       / order 'Patient/ID';
   define  discharge_da     / display width=10 'Discharge/Date';
   define  days0_through_30 / display width=10 'Days 0-30';
   define  days31_through90 / display width=10 'Days 31-90';
run;
