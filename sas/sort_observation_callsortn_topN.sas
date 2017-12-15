options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: sort_observation_callsortn_topN.sas
  *
  *  Summary: Sort within an observation
  *
  *  Created: Tue 06 Jun 2017 15:09:05 (Bob Heckel) 
  *---------------------------------------------------------------------------
  */
options source NOcenter dsoptions=note2err;

data t;
  input Score1-Score5;

  call sortn(of Score1-Score5);
  MeanTopThree = mean(of Score3-Score5);

  datalines;
80 70 90 10 80
  ;
run;
proc print data=_LAST_(obs=max) width=minimum; run;


 /* same */
data t;
  input Score1-Score5;
  datalines;
80 70 90 10 80
  ;
run;

data t2;
  set t;
  array Scores[*] Score:;
  /* Sort just 1st 3 elements i.e. Score1, 2, 3 */
  /* array Score[3]; */
  call sortn(of Scores[*]);
  MeanTopThree = mean(of Score3-Score5);
run;
proc print data=_LAST_(obs=max) width=minimum; run;
