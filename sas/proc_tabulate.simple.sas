options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: proc_tabulate.simple.sas
  *
  *  Summary: Demo of simple proc tabulate output
  *
  *  Created: Wed 25 Jun 2008 10:35:30 (Bob Heckel -- 264-2008 SUGI paper)
  * Modified: Wed 13 Jun 2012 14:38:20 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source NOcenter ls=80;

proc print data=sashelp.PRDSAL2(obs=5) width=minimum; run;


 /* Sum is default */
proc tabulate data=sashelp.PRDSAL2;
  class country;  /* usually discrete categorical CHAR */
  var actual;  /* usually analysis NUM */
  table actual, country;  /* singular table 1 */
  table country, actual;  /* singular table 2 */
run;


/*
--------------------------+-------------------------------------- 
|                         |             Actual Sales             |
|                          -------------------------------------- 
|                         |                 Mean                 |
|                          -------------------------------------- 
|      Actual Sales       |               Country                |
 ------------+------------ ------------+------------+------------ 
|     N      |    Mean    |   Canada   |   Mexico   |   U.S.A.   |
 ------------ ------------ ------------ ------------ ------------ 
|    23040.00|      651.40|      693.97|      458.06|      701.65|
 ------------ ------------ ------------ ------------ ------------ 
*/
proc tabulate data=sashelp.PRDSAL2;
  class country;  /* usually CHAR */
  var actual;  /* usually NUM */
  table actual * (N MEAN) actual * MEAN * country;
run;


/*
---------+----------------------------------------------------------- 
|Box     |                       Actual Sales                        |
|Label    -------------------+-------------------+------------------- 
|        |         N         |       Mean        |        Max        |
 -------- ------------------- ------------------- ------------------- 
|Country |                   |                   |                   |
 --------                    |                   |                   |
|Canada  |               4608|                694|               1566|
 -------- ------------------- ------------------- ------------------- 
|Mexico  |               4608|                458|               1068|
 -------- ------------------- ------------------- ------------------- 
|U.S.A.  |              13824|                702|               3516|
 -------- ------------------- ------------------- ------------------- 
|All     |              23040|                651|               3516|
 -------- ------------------- ------------------- ------------------- 
*/
proc tabulate data=sashelp.PRDSAL2 f=19.;
  class country;
  var actual;
  /*                                             Country width-includes bars */
  /*                                                            ______       */
  table (country ALL) , actual * (N MEAN MAX) / box='Box Label' rts=10;
run;



endsas;
proc tabulate data=l.legenealogy01a;
  where prod_nm =: 'Ven';
  class prod_nm mfg_batch pkg_batch;
  table prod_nm, mfg_batch, pkg_batch;
run;

proc tabulate data=l.lelimssumres01aleak format=F12.;
  class samp_id specname;
  tables samp_id , specname;
run;
