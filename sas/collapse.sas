/*----------------------------------------------------------------------------
 * Program Name: collapse.sas
 *
 *      Summary: Collapsing Observations within a BY Group into a Single
 *               Observation.
 *
 *               See also collapse_multrows_to_singlerow.sas
 *
 *
 *               1  2  3
 *               4  5  6
 *               7  8  9
 *               10 11 12
 *               
 *               becomes 1 2 3 4 5 6 7 ...
 *
 *               or 
 *
 *               anne math 98
 *               anne science 88
 *               anne english 87
 *               anne music 90
 *               mike math 100
 *               mike science 99
 *               mike english 97
 *               
 *               becomes
 *               1     math     science    english    music          98       88        87        90      anne
 *               2     math     science    english           .      100       99        97         .      mike
 *
 *  Adapted: Mon Jun 07 1999 16:03:03 (Bob Heckel)
 * Modified: Thu 10 Sep 2009 11:15:18 (Bob Heckel -- SUGI 354-2009)
 * Modified: Wed 17 Jan 2018 14:31:13 (Bob Heckel)
 *----------------------------------------------------------------------------
 */
options linesize=80 pagesize=32767 nodate source source2 notes mprint
        symbolgen mlogic obs=max errors=5 nostimer number serror merror
        noreplace;

data one;
  input x y z;
  datalines;
1  2  3
4  5  6
7  8  9
10 11 12
  ;
run;
proc print data=_LAST_(obs=max) width=minimum; run;

data _null_;
  call symput('CNT', attrn(open('one'), 'NOBS'));
run;

data define (drop=x y z i j);
  set one end=e;

  /* Create an array ALL to hold all the values in the data set.  The first
   * dimension is the number of rows in your data set.  The second dimension
   * is the number of variables  or columns in your data set.  In this sample,
   * 4*3=12, so we need to  specify twelve new variables in the array element
   * list, A1-A12. 
   */
  ***array all[4,3] a1-a12;
  array all[&CNT,3] a1-a12;

  /* A second array, VARS, contains all the variables in the data set.   */
  array vars[*] x y z;
  
  /* RETAIN the new array values A1-A12 so the values are not reinitialized to
   * missing when the DATA step iterates. 
   */
  retain a1-a12;
 
  i+1;

  /* For every variable in the DATA set (3 in this case), assign its value
   * into a new variable in the ALL array. 
   */
  do j=1 to 3;
    all[i,j]=vars[j];
  end;

  put a1-a12;

  /* Only output a single obs after all the reshaping is done...when we are on
   * the last observation of the dataset. 
   */
  if e then output;
run;
title "&SYSDSN";proc print data=_LAST_ width=minimum heading=H;run;title;
/*
WORK    DEFINE                                                                 2

Obs    a1    a2    a3    a4    a5    a6    a7    a8    a9    a10    a11    a12

 1      1     2     3     .     .     .     .     .     .      .      .      .
 2      1     2     3     4     5     6     .     .     .      .      .      .
 3      1     2     3     4     5     6     7     8     9      .      .      .
 4      1     2     3     4     5     6     7     8     9     10     11     12  <---
*/



 /* Unrelated example */

data students;
  input name:$ score;
  cards;
Deborah      89
Deborah      90
Deborah      95
Martin       90
Stefan       89
Stefan       76
;

data scores(keep=name score1-score3);
  retain name score1-score3;
  array scores[*] score1-score3;
  set students;
  by name;
  if first.name then do;
     i=1;
     do j=1 to 3;
        scores[j]=.;
     end;
  end;
  scores[i]=score;
  if last.name then output;
  i+1;
run;
title "&SYSDSN";proc print data=_LAST_(obs=10) width=minimum heading=H;run;title;
/*
WORK    SCORES                                                                 3

Obs     name      score1    score2    score3

 1     Deborah      89        90        95  
 2     Martin       90         .         .  
 3     Stefan       89        76         .  
*/



data students2;
  input name $ class $ grade ;
  datalines;
anne math 98
anne science 88
anne english 87
anne music 90
mike math 100
mike science 99
mike english 97
  ;
run;
proc print data=_LAST_(obs=max) width=minimum; run;

 /* Downside - have to know 4 is the max grouping via a prior proc freq */
proc freq data=students2 order=freq;
  tables name/ nocum;
run;

data out (keep=name subj: score:);
  retain subj1-subj4 score1-score4;
  array subj[4] $ subj1-subj4;
  array score[4] score1-score4;
  set students2;
  by name;
  if first.name then do;
    i=1;
    /* Not all students take 4 classes so protect here - set all array variables
     * to missing so that variables from BY groups with more observations than
     * the previous BY group don't carry values over to the current BY group.
     */
    do j=1 to dim(subj);
      subj[j]=.;
      score[j]=.;
    end;
  end;
  subj[i]=class;
  score[i]=grade;
  if last.name then output;
  i+1;
  put _ALL_;  /* debugging */
run;
 /*
Obs    subj1     subj2      subj3      subj4      score1    score2    score3    score4    name

 1     math     science    english    music          98       88        87        90      anne
 2     math     science    english           .      100       99        97         .      mike
 */
proc print data=_LAST_(obs=max) width=minimum; run;
