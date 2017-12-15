options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: long_to_wide_wo_transpose.sas
  *
  *  Summary: Demo of transposing normalized long rows "tall & skinny" to wide
  *           columns without proc transpose
  *
  *           See also lag.sas
  * 
  *  Created: Fri 24 Jun 2011 14:42:10 (Bob Heckel)
  * Modified: Wed 09 Oct 2013 09:44:13 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source NOcenter;

 /* Complex, not using PROC TRANSPOSE.  Adapted from http://support.sas.com/resources/papers/proceedings09/354-2009.pdf */
data long;
  input name $ classname $ grade ;
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

 /* Why we use '4' for the array max dim */
proc freq data=long order=freq;
  tables name / nocum;
run;

data wide(keep= name subj1-subj4 score1-score4);
  retain subj1-subj4 score1-score4;

  array subj (4) $ subj1-subj4;
  array score (4)  score1-score4;

  set long;
  by name;

  /* Some BY groups have fewer than four observations, so it's necessary to set all array variables 
   * to missing so that variables from BY groups with more observations than the previous BY group 
   * don't carry values over to the current BY group
   */
  if first.name then do;
    i=1;
    /* V9 */
/***    call missing(of subj(*),of score(*));***/
    /* V8 */
    do j=1 to 4; subj(j)=''; score(j)=.; end;
  end;

  subj(i)=classname;
  score(i)=grade;

  if last.name then output;
  i+1;
run;
proc print data=_LAST_(obs=max) width=minimum; run;
/*
 Obs    subj1     subj2      subj3     subj4    score1    score2    score3    score4    name

   1     math     science    english    music       98       88        87        90      anne
   2     math     science    english               100       99        97         .      mike
*/


 /*********************/

data long;
  input product $ invoice $ invoiceamt invoicedt $;
  cards;
ABC I123 10 990125
ABC J123 20 990126
DEF I456  5 990229
GHI I789 10 990325
GHI J789 20 990325
GHI K789 30 990301
GHI L789 99 990201
  ;
run;
proc print data=_LAST_(obs=max) width=minimum; run;

proc sql;
  create table wide as
  select product, sum(Jan) as Jan, sum(Feb) as Feb, sum(Mar) as Mar
  from (select product,
               case when substr(invoicedt,3,2) eq '01' then invoiceamt end as Jan,
               case when substr(invoicedt,3,2) eq '02' then invoiceamt end as Feb,
               case when substr(invoicedt,3,2) eq '03' then invoiceamt end as Mar
        from long)
  group by product
  ;
quit;
proc print data=_LAST_(obs=max) width=minimum; run;
/* 
Obs    product    Jan    Feb    Mar

 1       ABC       30      .      .
 2       DEF        .      5      .
 3       GHI        .     99     60
*/



 /*********************/

data wide;
  input id $ s1 s2 s3 s4;
  cards;
A01 33 44 55 99
A02 44 . 0  11
  ;
run;
title 'WIDE';
proc print data=_LAST_(obs=max) width=minimum; run;

data long;
  set wide;

  array arr s:;
  do i=1 to dim(arr);
    snumber = i;
    value = arr{i};
    if not missing(value) then output;
  end;
run;
title 'LONG';
proc print data=_LAST_(obs=max) width=minimum; var id snumber value;run;
/*
LONG

Obs    id     snumber    value

 1     A01       1         33 
 2     A01       2         44 
 3     A01       3         55 
 4     A01       4         99 
 5     A02       1         44 
 6     A02       3          0 
 7     A02       4         11 
*/

data longbacktowide;
  set long;
  by id;
  retain s:;

  array arr s:;
  /* Since we know there's a missing value that we want put back into WIDE, do 
   * this initialization to avoid RETAIN filling it wrongly.
   */
  if first.id then do;
    ***s1=.; s2=.; s3=.;
    do i=1 to dim(arr);
      arr{i}=.;
    end;
  end;

  ***if snumber eq 1 then s1 = value;
  ***else if snumber eq 2 then s2 = value;
  ***else if snumber eq 3 then s3 = value;
  ***else s4 = value;
  do j=1 to dim(arr);
    if snumber eq j then arr{j} = value;
  end;

  if last.id;
  drop snumber value i j;
run;
title 'WIDE again';
proc print data=_LAST_(obs=max) width=minimum; run;
