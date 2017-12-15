 /* Count distinct y where x is less than 30.  In the dataset, there are in
  * total 3 cases in variable 'y' when x < 30. Whereas distinct number of cases
  * in variable 'y' is equal to 2.
  */
data t;
  input id x y ;
  cards;
1 25 30
1 28 30
1 40 25
2 23 54
2 34 54
2 35 56
  ;
run;


proc sql;
  select count(distinct y) as unique_y, count(distinct case when x<30 then y end) as unique_y_basedoncriteria
  from t
  ;
quit;


 /* Group values by ID and then calculate sum of distinct values of y when x < 30. If condition is not met, then sum of all values of y */
proc sql;
  select id, sum(distinct y) as unique_y,
         coalesce(sum(distinct case when x<30 then y end),0) + coalesce(sum(distinct case when x>=30 then y end),0) as unique_y_basedoncriteria
  from t
  group by 1
  ;
quit;
/*

1         30+25=55          30+25=55
2         54+56=110      54+54+56=164

                            unique_y_
      id  unique_y    basedoncriteria
-------------------------------------
       1        55                 55
       2       110                164
*/
