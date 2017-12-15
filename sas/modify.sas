options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: modify.sas
  *
  *  Summary: Demo of the MODIFY statement.
  *
  *            When you use a MODIFY statement in a DATA step, unlike MERGE,
  *            SET & UPDATE, SAS does not create a new copy of the data set. As
  *            a result, the data set descriptor cannot change. 
  *
  *  Created: Tue 17 Jun 2003 13:27:48 (Bob Heckel)
  * Modified: Mon 23 Feb 2009 09:39:05 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source;

data master;
  set sashelp.shoes(obs=9);
run;

data master;
  set master;
  if Product eq 'Sandal' then Sales = 9;
run;
/***proc print data=_LAST_(obs=max) width=minimum; run;***/

 /* same */
data master;
  set sashelp.shoes(obs=9);
run;

data master;
  modify master;
  if Product eq 'Sandal' then Sales = 9;
run;
/***proc print data=_LAST_(obs=max) width=minimum; run;***/


 /*~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/


data master;
  set sashelp.class(obs=9);
run;
/***proc print data=_LAST_(obs=max) width=minimum; run;***/

 /* Dummy-up */
data trans(drop=Weight);
  set sashelp.class(obs=9) end=e;
  if Age eq 13 then Age=67;
  if Name eq 'Barbara' then Age=.;
  output;
  if e then do Name='Jeff'; output; end;
run;
/***proc print data=_LAST_(obs=max) width=minimum; run;***/

 /* No need to sort like UPDATE but could hinder performance */
data master;
  modify master trans;
  by Name;
  if _IORC_ eq 0 then replace;
  else output;
run;
/***title 'default is for missings to not replace existing data on master';***/
/***proc print data=master(obs=max) width=minimum; run;***/


 /*~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/


 /* Adapted http://support.sas.com/documentation/cdl/en/lestmtsref/63323/HTML/default/viewer.htm#n0g9jfr4x5hgsfn17gtma5547lt1.htm */

data stock(index=(partno));
  input PARTNO $ DESC $ INSTOCK @17 RECDATE date7. @25 PRICE;
  format recdate date7.;
  datalines;
K89R seal   34  27jul95 245.00
M4J7 sander 98  20jun95 45.88
LK43 filter 121 19may96 10.99
MN21 brace 43   10aug96 27.87
BC85 clamp 80   16aug96 9.55
NCF3 valve 198  20mar96 24.50
KJ66 cutter 6   18jun96 19.77
UYN7 rod  211   09sep96 11.55
JD03 switch 383 09jan97 13.99
BV1E timer 26   03jan97 34.50
  ;
run;
proc print data=stock(obs=max) width=minimum; run;

data stock stock95 stock97;
  modify stock;

  if recdate > '01jan97'd then do;
    output stock97;
    remove stock;
  end;
  else if recdate < '01jan96'd then do;
    output stock95;
    remove stock;
  end;
  else do;
    price = price*1.1;
    replace stock;
  end;
run;
proc print data=stock(obs=max) width=minimum; run;
proc print data=stock95(obs=max) width=minimum; run;
proc print data=stock97(obs=max) width=minimum; run;

