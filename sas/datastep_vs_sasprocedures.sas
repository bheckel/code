options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: datastep_vs_sasprocedures.sas
  *
  *  Summary: Compare two approaches to one problem.
  *
  *           The procs tend to save effort by not doing proc sorts first.
  *
  *  Adapted: Wed 15 Feb 2012 11:28:03 (Bob Heckel -- SUGI Paper 259-2011)
  *---------------------------------------------------------------------------
  */
options source NOcenter;

title '*************** Number of obs in a BY group ***************';
proc sort data=SASHELP.class out=class(keep=age);
  by age;
run;

data class1;
  set class;
  by age;
  if first.age then count=0;
  count+1;
  if last.age then output;
run;
proc print noobs; run;

 /* Same */
proc freq data=sashelp.class;
  tables age / out=new(drop=percent);
run;
proc print data=new noobs; run;
 /***********************************************************/


title '*************** Total for a BY group ***************';
data scores;
  input ID $ Game1 Game2 ;
  cards;
A 2 3
A 5 6
B 1 2
C 1 2
C 4 5
C 7 8
  ;
run;

proc sort data=scores; by ID; run;
data grandtot(drop=temp1 temp2);
  set scores(rename= (Game1=temp1 Game2=temp2));
  by id;
  if first.id then do;
    Game1=0;
    Game2=0;
  end;
  Game1 + temp1;
  Game2 + temp2;
  if last.ID then output;
run;
proc print data=grandtot noobs; run;

 /* Same */
proc means data=scores noprint nway;
  class ID;
  var Game1 Game2;
  output out=new(drop=_type_ _freq_) sum=;
run;
proc print data=new noobs; run;
 /****************************************************/


title '*************** Average for a BY group ***************';
data test;
  input I J X;
  cards;
1 1 123
1 1 3245
1 2 23
1 2 543
1 2 87
1 3 90
2 1 88
2 1 86
  ;
run;

proc sort data=test; by I J; run;
data jsubtot (keep=I j freq average);
  set test;
  by I J;
  retain jsub Freq;
  if first.J then do;
    jsub=0;
    freq=0;
  end;
  jsub + X;
  freq + 1;
  if last.J then do;
    Average=jsub/freq;
    output;
  end;
run;
proc print data=jsubtot noobs; run;

 /* Same */
proc means data=test noprint nway;
  class I J;
  var x;
  output out=I_J(drop=_TYPE_ rename=(_freq_=Freq)) mean=Average;
run;
proc print data=I_J noobs; run;
 /******************************************************/


title '*************** Percentage for a BY group ****************';
data sales;
  input @1 Region $char8. @10 Repid 4. @15 Amount 10. ;
  format Amount dollar12.;
  cards;
NORTH    1001 1000000
NORTH    1002 1100000
NORTH    1003 1550000
NORTH    1008 1250000
NORTH    1005  900000
SOUTH    1007 2105000
SOUTH    1010  875000
SOUTH    1012 1655000
EAST     1051 2508000
EAST     1055 1805000
  ;
run;

proc sort data=sales; by Region; run;
proc means data=sales noprint nway;
  by Region;
  var Amount;
  output out=Regtot(keep=Regtotal Region) sum=Regtotal;
run;

data percent1;
  merge sales Regtot;
  by Region;
  Regpct=(Amount / Regtotal ) * 100;
  format regpct 6.2 Amount Regtotal dollar10.;
run;
proc print data=percent1 noobs; run;


 /* Almost same */
proc tabulate data=sales out=out_tab;
  class Region Repid;
  var Amount;
  table Region*Repid, Amount*(Sum*f=dollar12. Pctsum<Repid>);
run;


 /* Almost same */
proc report data=sales nowd out=out_rep;
  column Region Repid Amount Regpct;
  define Region / order;
  define Repid / display;
  define Amount / sum format=dollar12.;
  define Regpct / computed format=percent8.2;
  compute before Region;
    hold=Amount.sum;
  endcomp;
  compute Regpct;
    regpct=Amount.sum/hold;
  endcomp;
run;
 /**********************************************************/


title '*************** Displaying values that do not exist in the data ****************';
data student;
  input Grades $ verbal $;
  cards;
A ay
B bee
D dee
  ;
run;
data student;
  set student end=eof;
  output;
  if eof then do;
    Grades='C'; verbal='cee'; output;
    Grades='F'; verbal='eff'; output;
  end;
run;
proc print data=student noobs; run;

proc format;
  value $Grade 'A'='A' 'B'='B' 'C'='C' 'D'='D' 'F'='F';
run;

 /* Almost same */
proc means data=student nway noprint completetypes;
  class Grades / preloadfmt;
  format Grades $Grade.;
  output out=new(drop=_type_ _freq_);
run;
proc print data=new noobs; run;
 /**********************************************************/


title '*************** Custom report **************************';
proc sort data=sashelp.class out=sorted; by sex; run;

data _null_;
  set sorted;
  by sex;

  file print header=h notitles;

  if first.sex then put _page_;

  put name 1-8 age 13-15 @20 sex +5 weight 5.1 +5 height;
  return;
  h:
  n+1;
  put @35 "Page " n " of 2" //;
  put @1 "Name" @13 "Age" @20 "Sex" @26 "Weight" @36 "Height";
  put @1 "----" @13 "---" @20 "---" @26 "------" @36 "------";
  return;
run;


 /* Almost same */
proc report data=sorted nowd;
  column sex name age sex=sex1 weight height;
  define sex / order noprint;
  define name / order 'Name/--';
  define age / order 'Age/--' width=4;
  define sex1 / order 'Sex/--' width=3;
  define weight / display 'Weight/--' width=7;
  define height / display 'Height/--' width=7;
  break after sex / page;
run;
 /**********************************************************/


title '*************** Transpose Tall to Wide ******************';
data students;
  input Name:$ Score;
  cards;
Deborah 89
Deborah 90
Deborah 95
Martin 90
Stefan 89
Stefan 76
  ;
run;

 /* Must know number of vars, e.g. 3 here */
data scores(keep=Name Score1-Score3);
  retain name Score1-Score3;
  array scores(*) Score1-Score3;
  set students;
  by name;
  if first.name then do;
    i=1;
    do j=1 to 3;
      scores(j)=.;
    end;
  end;
  scores(i)=score;
  if last.name then output;
  i+1;
run;
proc print noobs; run;

 /* Much better */
proc transpose data=students out=new(drop=_name_) prefix=score;
  by name;
  var score;
run;

proc print data=new noobs; run;
 /**********************************************************/
