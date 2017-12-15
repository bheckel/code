options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: sumif_exceed_thresh.sas
  *
  *  Summary: Sum only after exceeding a threshold.
  *
  *  Created: Tue 10 Jun 2003 12:25:20 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source;

data tmp;
  input emp $  hrs;
  cards;
aa 5
aa 1
bb 10
bb 2
bb 1
cc 50
cc 11
dd 100
  ;
run;


 /* Who worked less than 40 hours this week? */
proc sql;
  select emp, sum(hrs) from tmp
  group by emp
  /* 40 is threshold. */
  having sum(hrs)<40;
quit;
