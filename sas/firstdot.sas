options nosource;
 /*---------------------------------------------------------------------------
  *     Name: firstdot.sas (see also lastdot.sas for a shorter example)
  *
  *  Summary: Demo of counting the number of records for each ID using 
  *           first-dot and last-dot, automatic boolean SAS variables
  *
	*           See also sum_group_add_obs.sas, bygroup_processing.sas
  *
  *  Created: Wed 19 Jun 2002 17:07:14 (Bob Heckel)
  *  Adapted: Wed 09 May 2018 09:53:45 (Bob Heckel -- https://blogs.sas.com/content/iml/2018/02/26/how-to-use-first-variable-and-last-variable-in-a-by-group-analysis-in-sas.html) 
  *---------------------------------------------------------------------------
  */
options source;

data Patients;
  informat Date date7.;
  format Date date7. PatientID Z4.;
  input PatientID Date Weight @@;
  datalines;
1021 04Jan16  302  1042 06Jan16  285
1053 07Jan16  325  1063 11Jan16  291
1053 01Feb16  299  1021 01Feb16  288
1063 09Feb16  283  1042 16Feb16  279
1021 07Mar16  280  1063 09Mar16  272
1042 28Mar16  272  1021 04Apr16  273
1063 20Apr16  270  1053 28Apr16  289
1053 13May16  295  1063 31May16  269
  ;
run;

proc sort data=Patients;
  by PatientID Date;
run;
 
data weightLoss;
   set Patients;
   by PatientID;                               /* create two indicator variables - FIRST. to initialze a summary statistic and LAST. to output */ 
   retain startDate startWeight;               /* RETAIN the starting values */
   if FIRST.PatientID then do;
      startDate = Date; startWeight = Weight;  /* remember the initial values */
   end;
   if LAST.PatientID then do;
      endDate = Date; endWeight = Weight;
      elapsedWeeks = intck('WEEK', startDate, endDate);
      weightLoss = startWeight - endWeight;
      AvgWeightLossPerWk = weightLoss / elapsedWeeks;
      output;                                  /* output only the last record in each group */
   end;
run;
 
proc print noobs; 
  var PatientID elapsedWeeks startWeight endWeight weightLoss AvgWeightLossPerWk;
run;
/*
                                                      Avg
Patient    elapsed     start      end     weight     Weight
  ID         Days     Weight    Weight     Loss       Loss

 1021         91        302       273       29      0.31868
 1042         82        285       272       13      0.15854
 1053        127        325       295       30      0.23622
 1063        141        291       269       22      0.15603
*/



endsas;
data t;
   input x $ y $ 9-17 z $ 19-26; 
   datalines; 
apple   banana    coconut
apple   banana    coconut 
apple   banana    coconut2
apple   blueberry citron
apricot blueberry citron
; 
run;
proc print data=_LAST_(obs=max) width=minimum; run;

proc sql;
  select distinct *
  from t
  ;
  select distinct x, y
  from t
  ;
quit;

proc sort; by x y;run;
/***proc sort; by x y z;run;***/

data t2;
  set t;
  by x y;
  if first.x or last.x;
  put _N_= x= first.x= last.x= first.y= last.y= first.z= last.z= ;
run;
title "ds:&SYSDSN";proc print data=_LAST_(obs=max) width=minimum heading=H; run;title;
endsas;

data _null_;
   set t;
   by x y z;
   if _N_=1 then put 'Grouped by X Y Z';
   put _N_= x= first.x= last.x= first.y= last.y= first.z= last.z= ;
run; 

data _null_;
   set t;
   by y x z;
   if _N_=1 then put 'Grouped by Y X Z';
   put _N_= x= first.x= last.x= first.y= last.y= first.z= last.z= ;
run;


data work.sample1;
  input fname $1-10  lname $15-25  @30 storeno 3.;
  datalines;
iyn           rand           123
iyn           rand           123
ron           francis        123
jerry         varcia         123
lola          rennt          345
larry         wally          345
richard       stallmen       345
IAM           UNIQUE         901
richard       dawkins        345
charles       heston         678
richard       feznman        678
  ;
run;
proc print data=_LAST_; run;


proc sort data=work.sample1;
  by storeno;
run;

data _null_;
  set sample1;
  by storeno;
  put _all_;  /* print PDV */
run;


data _null_;
  set work.sample1;
  by storeno;
  /* FIRST.storeno is 1 on the first obs, 0 otherwise. */
  if first.storeno then 
    cnt=1;
  else
    cnt+1;

  if last.storeno then
    put cnt= storeno=;

  if first.storeno and last.storeno then
    put 'there is only one of these unique values: ' storeno;
run;


data showdupsonly;
  set sample1;
  by storeno;
  /* Removing any unique (ie single obs) stores */
  if first.storeno and last.storeno then
    delete;
run;
proc print data=_LAST_(obs=max); run;


data showssinglesonly;
  set sample1;
  by storeno;
  /* Keeping only single obs stores */
  if first.storeno and last.storeno;
  /* By contrast NODUPKEY on the above sort would NOT have done what you want:
   *
   *  Obs    fname      lname     storeno
   *
   *   1     iyn        rand        123  
   *   2     lola       rennt       345  
   *   3     charles    heston      678  
   *   4     IAM        UNIQUE      901  
   *
   */
run;
proc print data=_LAST_(obs=max); run;


 /* Compare */
proc sql;
  select *
  from sample1
  group by storeno
  having count(storeno) = 1
  ;
quit;



 /* Add an obs for each desired CI group */
data l.t;
  set l.ci_ind_60;
  by SampId mfg_batch studyID storage_condition time_point device;

  if first.device then 
    sum012 = 0;

  if test eq 'AS_CI_0' then
    sum012+result;
  else if test eq 'AS_CI_1' then
    sum012+result;
  else if test eq 'AS_CI_2' then
    sum012+result;

  output;  /* individual */

  if last.device then do;
    test = 'AS_CI_SUM012';
    result = sum012;
    output;  /* group */
  end;
run;

