
/* __________Several ways to tune a SORT__________ */
Proc sort data=x threads ; 
  By y ;
Run ;
Proc sort data=x tagsort ;
  By y ;
Run ;
proc sort data=data-set NOEQUALS ;
  by y ;
run ;
Options sortwkno=6 ;
proc sort data=xxx(where=(price>1000)) out=yyy ;
  by y ;
run;
options sortsize=max ;
proc print data=calendar ;
  by month NOTSORTED ;
run;
Data new(SORTEDBY=year month) ; 
   Set x.y ; 
run ;
