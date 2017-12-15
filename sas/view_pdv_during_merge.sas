options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: view_pdv_during_merge.sas
  *
  *  Summary: See internals of merge process.
  *
  *  Created: Fri 11 Sep 2009 12:38:02 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source NOcenter;

data left;
  input  id  x  y;
  put _all_;
  cards;
1   88   99
2   66   x7
3   44   55
  ;
run;
proc sort; by id; run;
proc print data=_LAST_(obs=max); run;

data right;
  input  id a $ b $;
  cards;
1   A14   B32
3   A53   B11
  ; 
run;
proc sort; by id; run;
proc print data=_LAST_(obs=max); run;

data both;
  put _ALL_;  /* print PDV to Log */
  merge left(in=inleft) right(in=inright);
  by id;
  put _ALL_;  /* print PDV to Log */
  put;
run;
title 'the Log output is more important in this demo'; proc print data=_LAST_(obs=max); run;
