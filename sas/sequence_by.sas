options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: sequence_by.sas
  *
  *  Summary: Sequence a dataset by its BY variable.  Count by groups.
  *
  *  Created: Mon 11 Dec 2006 11:13:10 (Bob Heckel)
  * Modified: Tue 25 Jul 2017 14:55:53 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source NOcenter;

 /* Sequence by region (e.g. any Africa is '1', any Asia is '2') */
data t;
  set sashelp.shoes;
  by region;
  if first.region then
    n+1;
run;
/* proc print data=_LAST_(obs=max); run; */


 /* Sub-sequence by region (e.g. Africa runs 1-50, Asia runs 1-50) */
data t;
  set sashelp.shoes;
  by region;
  if first.region then
    n=0;
  n+1;
run;
/* proc print data=_LAST_(obs=max); run; */


proc sort data=sashelp.shoes out=t; by region product; run;
data t;
  set t(keep=region product);
  by region product;
  put _all_;
  if first.product then n=0;
  n+1;
run;
proc print data=_LAST_(obs=max); run;
/*
Obs    Region                       Product           n

  1    Africa                       Boot              1
  2    Africa                       Boot              2
  3    Africa                       Boot              3
  4    Africa                       Boot              4
  5    Africa                       Boot              5
  6    Africa                       Boot              6
  7    Africa                       Boot              7
  8    Africa                       Boot              8
  9    Africa                       Men's Casual      1
 10    Africa                       Men's Casual      2
 11    Africa                       Men's Casual      3
 12    Africa                       Men's Casual      4
 13    Africa                       Men's Casual      5
 14    Africa                       Men's Dress       1
 15    Africa                       Men's Dress       2
 16    Africa                       Men's Dress       3
 17    Africa                       Men's Dress       4
 18    Africa                       Men's Dress       5
 19    Africa                       Men's Dress       6
 20    Africa                       Men's Dress       7
 21    Africa                       Sandal            1
 22    Africa                       Sandal            2
*/
