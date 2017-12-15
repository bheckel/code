options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: calc_percentage_from_sum_of_2_ds.sas
  *
  *  Summary: Sum 2 datasets then calculate the percentage of the 2 scalar sums
  *
  * Modified: Wed 13 Sep 2017 15:38:07 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source NOcenter dsoptions=note2err;

proc sql;
  create table tmp as 

  select sum(upid) as sumupid
  from report1_nRx
  
  union
  
  select sum(upid) as sumupid
  from report2_nRx
  ;
quit;

data tmp2(drop=sumupid);
  set tmp end=e;
  pct = lag(sumupid) / sumupid;
  if e then output;
run;

endsas;
 WORK    TMP                                             15:36 Wednesday, September 13, 2017   3

            Obs    sumupid

             1        500 
             2       3545 
 WORK    TMP2                                            15:36 Wednesday, September 13, 2017   4

            Obs      pct

             1     0.14104
