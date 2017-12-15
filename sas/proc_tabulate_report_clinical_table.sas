options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: proc_tabulate_report_clinical_table.sas
  *
  *  Summary: Compare tabulate & report for clinical trial reporting
  *
  *  Adapted: Fri 19 Sep 2014 10:04:11 (Bob Heckel -- Jack Shostak book)
  *---------------------------------------------------------------------------
  */
options source NOcenter dsoptions=note2err ps=38;

data demog;
  label subjid="Subject Number"
        trt="Treatment"
        gender="Gender"
        race="Race"
        age="Age";
  input subjid trt gender race age @@;
  datalines;
101 0 1 3 37 301 0 1 1 70 501 0 1 2 33 601 0 1 1 50 701 1 1 1 60
102 1 2 1 65 302 0 1 2 55 502 1 2 1 44 602 0 2 2 30 702 0 1 1 28
103 1 1 2 32 303 1 1 1 65 503 1 1 1 64 603 1 2 1 33 703 1 1 2 44
104 0 2 1 23 304 0 1 1 45 504 0 1 3 56 604 0 1 1 65 704 0 2 1 66
105 1 1 3 44 305 1 1 1 36 505 1 1 2 73 605 1 2 1 57 705 1 1 2 46
106 0 2 1 49 306 0 1 2 46 506 0 1 1 46 606 0 1 2 56 706 1 1 1 75
201 1 1 3 35 401 1 2 1 44 507 1 1 2 44 607 1 1 1 67 707 1 1 1 46
202 0 2 1 50 402 0 2 2 77 508 0 2 1 53 608 0 2 2 46 708 0 2 1 55
203 1 1 2 49 403 1 1 1 45 509 0 1 1 45 609 1 2 1 72 709 0 2 2 57
204 0 2 1 60 404 1 1 1 59 510 0 1 3 65 610 0 1 1 29 710 0 1 1 63
205 1 1 3 39 405 0 2 1 49 511 1 2 2 43 611 1 2 1 65 711 1 1 2 61
206 1 2 1 67 406 1 1 2 33 512 1 1 1 39 612 1 1 2 46 712 0 . 1 49
;
run;
proc print data=_LAST_(obs=max) width=minimum; run;

proc format;
  value trt 0='Placebo' 1='Active';
  value gender 1='Male' 2='Female';
  value race 1='White' 2='Black' 3='Other*';
run;

proc tabulate data=demog missing;
  class trt gender race;
  var age;
  table age = 'Age' * 
              (n = 'n' * f = 8. 
               mean = 'Mean' * f = 5.1 
               std = 'Standard Deviation' * f = 5.1
               min = 'Min' * f = 3. Max = 'Max' * f = 3.)
        gender = 'Gender' * 
              (n='n' * f = 3. colpctn = '%' * f = 4.1)
        race = 'Race' * 
              (n = 'n' * f = 3. colpctn = '%' * f = 4.1),
	 
        (trt = "  ") (all = 'Overall');

  format trt trt. race race. gender gender.;

  title1 'Table 5.1';
  title2 'Demographics and Baseline Characteristics';
  footnote1 "* Other includes Asian, Native American, and other" 
            " races.";
  footnote2 "Created by %sysfunc(getoption(sysin)) on"  
            " &sysdate9..";  
run;
/*
---------------------------------------------------------------+--------+--------+-------- 
|                                                              |Placebo | Active |Overall |
 ------------------------------+------------------------------- -------- -------- -------- 
|Age                           |n                              |      29|      31|      60|
|                               ------------------------------- -------- -------- -------- 
|                              |Mean                           |    50.1|    51.4|    50.8|
|                               ------------------------------- -------- -------- -------- 
|                              |Standard Deviation             |    13.2|    13.2|    13.1|
|                               ------------------------------- -------- -------- -------- 
|                              |Min                            |      23|      32|      23|
|                               ------------------------------- -------- -------- -------- 
|                              |Max                            |      77|      75|      77|
 ------------------------------ ------------------------------- -------- -------- -------- 
|Gender                        |                               |        |        |        |
 ------------------------------ -------------------------------         |        |        |
|.                             |n                              |       1|       .|       1|
|                               ------------------------------- -------- -------- -------- 
|                              |%                              |     3.4|       .|     1.7|
 ------------------------------ ------------------------------- -------- -------- -------- 
|Male                          |n                              |      16|      22|      38|
|                               ------------------------------- -------- -------- -------- 
|                              |%                              |    55.2|    71.0|    63.3|
 ------------------------------ ------------------------------- -------- -------- -------- 
|Female                        |n                              |      12|       9|      21|
|                               ------------------------------- -------- -------- -------- 
|                              |%                              |    41.4|    29.0|    35.0|
 ------------------------------ ------------------------------- -------- -------- -------- 
|Race                          |                               |        |        |        |
 ------------------------------ -------------------------------         |        |        |
|White                         |n                              |      18|      18|      36|
|                               ------------------------------- -------- -------- -------- 
|                              |%                              |    62.1|    58.1|    60.0|
 ------------------------------ ------------------------------- -------- -------- -------- 
|Black                         |n                              |       8|      10|      18|
|                               ------------------------------- -------- -------- -------- 
|                              |%                              |    27.6|    32.3|    30.0|
 ------------------------------ ------------------------------- -------- -------- -------- 
|Other*                        |n                              |       3|       3|       6|
|                               ------------------------------- -------- -------- -------- 
|                              |%                              |    10.3|     9.7|    10.0|
 ------------------------------ ------------------------------- -------- -------- -------- 
*/

**** DUPLICATE THE INCOMING DATA SET FOR OVERALL COLUMN 
**** CALCULATIONS SO NOW TRT HAS VALUES 0 = PLACEBO, 1 = ACTIVE,
**** AND 2 = OVERALL.;
data demog;
   set demog;
   output;
   trt = 2;
   output;
run;


**** AGE STATISTICS PROGRAMMING ********************************;
**** GET P VALUE FROM NON PARAMETRIC COMPARISON OF AGE MEANS.;
proc npar1way 
   data = demog
   wilcoxon 
   noprint;
      where trt in (0,1);
      class trt;
      var age;
      output out = pvalue wilcoxon;
run;

proc sort 
   data = demog;
      by trt;
run;
 
***** GET AGE DESCRIPTIVE STATISTICS N, MEAN, STD, MIN, AND MAX.;
proc univariate 
   data = demog noprint;
      by trt;

      var age;
      output out = age 
             n = _n mean = _mean std = _std min = _min 
             max = _max;
run;

**** FORMAT AGE DESCRIPTIVE STATISTICS FOR THE TABLE.;
data age;
   set age;

   format n mean std min max $14.;
   drop _n _mean _std _min _max;

   n = put(_n,3.);
   mean = put(_mean,7.1);
   std = put(_std,8.2);
   min = put(_min,7.1);
   max = put(_max,7.1);
run;

**** TRANSPOSE AGE DESCRIPTIVE STATISTICS INTO COLUMNS.;
proc transpose 
   data = age 
   out = age 
   prefix = col;
      var n mean std min max;
      id trt;
run; 
 
**** CREATE AGE FIRST ROW FOR THE TABLE.;
data llabel;
   set pvalue(keep = p2_wil rename = (p2_wil = pvalue));
   length label $ 85;
   label = "Age (years)";
run;
 
**** APPEND AGE DESCRIPTIVE STATISTICS TO AGE P VALUE ROW AND 
**** CREATE AGE DESCRIPTIVE STATISTIC ROW LABELS.; 
data age;
   length label $ 85 col0 col1 col2 $ 25 ;
   set llabel age;

   keep label col0 col1 col2 pvalue ;
   if _n_ > 1 then 
      select;
         when(_NAME_ = 'n')    label = "     N";
         when(_NAME_ = 'mean') label = "     Mean";
         when(_NAME_ = 'std')  label = "     Standard Deviation";
         when(_NAME_ = 'min')  label = "     Minimum";
         when(_NAME_ = 'max')  label = "     Maximum";
         otherwise;
      end;
run;
**** END OF AGE STATISTICS PROGRAMMING *************************;

 
**** GENDER STATISTICS PROGRAMMING *****************************;
**** GET SIMPLE FREQUENCY COUNTS FOR GENDER.;
proc freq 
   data = demog 
   noprint;
      where trt ne .; 
      tables trt * gender / missing outpct out = gender;
run;
 
**** FORMAT GENDER N(%) AS DESIRED.;
data gender;
   set gender;
      where gender ne .;
      length value $25;
      value = put(count,4.) || ' (' || put(pct_row,5.1)||'%)';
run;

proc sort
   data = gender;
      by gender;
run;
 
**** TRANSPOSE THE GENDER SUMMARY STATISTICS.;
proc transpose 
   data = gender 
   out = gender(drop = _name_) 
   prefix = col;
      by gender;
      var value;
      id trt;
run;
 
**** PERFORM CHI-SQUARE ON GENDER COMPARING ACTIVE VS PLACEBO.;
proc freq 
   data = demog 
   noprint;
      where gender ne . and trt not in (.,2);
      table gender * trt / chisq;
      output out = pvalue pchi;
run;

**** CREATE GENDER FIRST ROW FOR THE TABLE.;
data lllabel;
   set pvalue(keep = p_pchi rename = (p_pchi = pvalue));
   length label $ 85;
   label = "Gender";
run;

**** APPEND GENDER DESCRIPTIVE STATISTICS TO GENDER P VALUE ROW
**** AND CREATE GENDER DESCRIPTIVE STATISTIC ROW LABELS.; 
data gender;
   length label $ 85 col0 col1 col2 $ 25 ;
   set lllabel gender;

   keep label col0 col1 col2 pvalue ;
   if _n_ > 1 then 
        label= "     " || put(gender,gender.);
run;
**** END OF GENDER STATISTICS PROGRAMMING **********************;

 
**** RACE STATISTICS PROGRAMMING *******************************;
**** GET SIMPLE FREQUENCY COUNTS FOR RACE;
proc freq 
   data = demog 
   noprint;
      where trt ne .; 
      tables trt * race / missing outpct out = race;
run;
 
**** FORMAT RACE N(%) AS DESIRED;
data race;
   set race;
      where race ne .;
      length value $25;
      value = put(count,4.) || ' (' || put(pct_row,5.1)||'%)';
run;

proc sort
   data = race;
      by race;
run;
 
**** TRANSPOSE THE RACE SUMMARY STATISTICS;
proc transpose 
   data = race 
   out = race(drop = _name_) 
   prefix=col;
      by race;
      var value;
      id trt;
run;
 
**** PERFORM FISHER'S EXACT ON RACE COMPARING ACTIVE VS PLACEBO.;
proc freq 
   data = demog 
   noprint;
      where race ne . and trt not in (.,2);
      table race * trt / exact;
      output out = pvalue exact;
run;
 
**** CREATE RACE FIRST ROW FOR THE TABLE.;
data lllllabel;
   set pvalue(keep = xp2_fish rename = (xp2_fish = pvalue));
   length label $ 85;
   label = "Race";
run;

**** APPEND RACE DESCRIPTIVE STATISTICS TO RACE P VALUE ROW AND 
**** CREATE RACE DESCRIPTIVE STATISTIC ROW LABELS.; 
data race;
   length label $ 85 col0 col1 col2 $ 25 ;
   set lllllabel race;

   keep label col0 col1 col2 pvalue ;
   if _n_ > 1 then 
        label= "     " || put(race,race.);
run;
**** END OF RACE STATISTICS PROGRAMMING ************************;


**** CONCATENATE AGE, GENDER, AND RACE STATISTICS AND CREATE
**** GROUPING GROUP VARIABLE FOR LINE SKIPPING IN PROC REPORT.;
data forreport;
   set age(in = in1)
       gender(in = in2)
       race(in = in3);

       group = sum(in1 * 1, in2 * 2, in3 * 3);
run;


**** DEFINE THREE MACRO VARIABLES &N0, &N1, AND &NT THAT ARE USED 
**** IN THE COLUMN HEADERS FOR "PLACEBO," "ACTIVE" AND "OVERALL" 
**** THERAPY GROUPS.;
data _null_;
   set demog end = eof;

   **** CREATE COUNTER FOR N0 = PLACEBO, N1 = ACTIVE.;
   if trt = 0 then
      n0 + 1;
   else if trt = 1 then
      n1 + 1;

   **** CREATE OVERALL COUNTER NT.; 
   nt + 1;
  
   **** CREATE MACRO VARIABLES &N0, &N1, AND &NT.;
   if eof then
      do;     
         call symput("n0",compress('(N='||put(n0,4.) || ')'));
         call symput("n1",compress('(N='||put(n1,4.) || ')'));
         call symput("nt",compress('(N='||put(nt,4.) || ')'));
      end;
run;


**** USE PROC REPORT TO WRITE THE TABLE TO FILE.; 
options nonumber nodate ls=84 missing = " "
        formchar="|----|+|---+=|-/\<>*";

proc report
   data = forreport
   nowindows
   spacing=1
   headline
   headskip
   split = "|";

   columns ("--" group label col1 col0 col2 pvalue);

   define group   /order order = internal noprint;
   define label   /display width=23 " ";
   define col0    /display center width = 14 "Placebo|&n0";
   define col1    /display center width = 14 "Active|&n1";
   define col2    /display center width = 14 "Overall|&nt";
   define pvalue  /display center width = 14 " |P-value**" 
                   f = pvalue6.4;

   break after group / skip;

   title1 "Company                                              "
          "                              ";
   title2 "Protocol Name                                        "
          "                              ";
   title3 "Table 5.3";
   title4 "Demographics";
 
   footnote1 "------------------------------------------"
             "-----------------------------------------";
   footnote2 "*  Other includes Asian, Native Amerian, and other"
             " races.                          ";
   footnote3 "** P-values:  Age = Wilcoxon rank-sum, Gender "  
             "= Pearson's chi-square,              ";
   footnote4 "              Race = Fisher's exact test. "
             "                                         ";
   footnote5 "Created by %sysfunc(getoption(sysin)) on" 
             " &sysdate9..";  
run;
/*
 -----------------------------------------------------------------------------------
                             Active        Placebo        Overall                   
                             (N=31)         (N=29)        (N=120)       P-value**   
 -----------------------------------------------------------------------------------
                                                                                    
 Age (years)                                                              0.9528    
      N                        31             29             60                     
      Mean                     51.4           50.1           50.8                   
      Standard Deviation       13.23          13.22          13.13                  
      Minimum                  32.0           23.0           23.0                   
      Maximum                  75.0           77.0           77.0                   
                                                                                    
 Gender                                                                   0.2681    
      Male                 22 ( 71.0%)    16 ( 55.2%)    38 ( 63.3%)                
      Female                9 ( 29.0%)    12 ( 41.4%)    21 ( 35.0%)                
                                                                                    
 Race                                                                     0.9270    
      White                18 ( 58.1%)    18 ( 62.1%)    36 ( 60.0%)                
      Black                10 ( 32.3%)     8 ( 27.6%)    18 ( 30.0%)                
      Other*                3 (  9.7%)     3 ( 10.3%)     6 ( 10.0%)                
                                                                                    
 
 
 
 
 
 
 
-----------------------------------------------------------------------------------
*  Other includes Asian, Native Amerian, and other races.                          
** P-values:  Age = Wilcoxon rank-sum, Gender = Pearson's chi-square,              
              Race = Fisher's exact test.                                          
Created by U:\code\sas\tmpsas.94632.sas on 19SEP2014.
*/
