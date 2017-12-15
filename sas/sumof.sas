 /*----------------------------------------------------------------------------
  *     Name: sumof.sas
  *
  *  Summary: Demo of 'sum of'.
  *
  *  Created: Thu Apr 29 1999 16:13:21 (Bob Heckel)
  * Modified: Tue 16 Nov 2004 16:25:53 (Bob Heckel)
  *----------------------------------------------------------------------------
  */

title 'Original';
data work.tmp;
  input idnum  qtr1  qtr2  qtr3  qtr4;
  cards;
1000  10  50  39  32
3000   5   4   3   2
4000  22  30  33  43
5000  39   3   1   500
;
run;
proc print; run;
title;


data work.sumofdemo2;
  set work.tmp;
  /* Use single dash if vars have same prefix. */
  tot = sum(of qtr1-qtr4);
  samething = sum(qtr1, qtr2, qtr3, qtr4);
  nodifference = qtr1 + qtr2 + qtr3 + qtr4;
  if tot >= 50;
  /* Use double dash to get first thru last vars. */
  grandtot = sum(of idnum--qtr4);
run;
proc print; run;


data work.sumofdemo3;
  /* Change, reorder, the order of PDV... */
  retain qtr1 qtr2 idnum qtr3 qtr4;
  set work.tmp;
  /* ...then select the range of variables after of the reordering. */
  grandtot = sum(of qtr1--qtr4);
run;


 /* Sum an array */
data work.sumofdemo4;
  set work.tmp;
  array tmp[*] idnum qtr1-qtr4;
  grandtot = sum(of tmp[*]);
run;


 /* Same as sumofdemo4. */
data work.sumofdemo5;
  set work.tmp;
  grandtot = sum(of _NUMERIC_);
run;


 /* Using the colon wildcard.  Similar to sumofdemo3,4,5. */
data work.sumofdemo6;
  set work.tmp;
  grandtot = sum(of qtr:);
run;
proc print; run;


 /* Even zero padded numbers work */
data _null_;
  x01=1;
  x02=1;
  x03=1;
  x04=1;
  x05=1;
  x06=1;
  x07=1;
  x08=1;
  x09=1;
  x10=1;
  x11=1;
  x12=1;
  x13=1;

  y=sum(of x01-x13);
  put y=;
run;
