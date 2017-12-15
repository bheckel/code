options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: proc_transpose.reverse_expand.sas
  *
  *  Summary: Flatten then unflatten, unflip.  eForms simulation.
  *
  *  Created: Wed 11 Feb 2009 11:20:36 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source NOcenter;

data ef;
  input reqid fieldname $ fieldval $;
  cards;
1 matlnum 10003
1 produ val1
1 batchn 7zm1231
1 thing1 61degree
1 thing2 91
2 matlnum 10004
2 produ val2
2 batchn 7zm1232
2 thing1 62degree
2 thing2 92
  ;
run;
title 'before, vertical'; proc print data=_LAST_(obs=max) width=minimum; run;

proc transpose data=ef;
  by reqid;
  id fieldname;
  var fieldval;
run;
title 'flatten to single line'; proc print data=_LAST_(obs=max) width=minimum; run;

/*----*/

data xl;
  input reqid matl prod $ batch $ thing1 $ thing2 $;
  cards;
1 10003 val1 7zm1231 61degree 91
2 10004 val2 7zm1232 62degree 92
  ;
run;
proc sql;CREATE INDEX x ON xl (reqid, batch, matl);quit;
title 'INPUT sb same as single line'; proc print data=_LAST_(obs=max) width=minimum; run;

proc transpose data=xl;
  by reqid;
  var matl batch prod thing1 thing2;
run;
title '"before, vertical" restored'; proc print data=_LAST_(obs=max) width=minimum; run;



endsas;
data fishdata;
  infile datalines missover;
  input Location & $10. Date date7. Length1 Weight1 Length2 Weight2 Length3 Weight3 Length4 Weight4;
  format date date7.;
  datalines;
Cole Pond   2JUN95 31 .25 32 .3  32 .25 33 .3
Cole Pond   3JUL95 33 .32 34 .41 37 .48 32 .28
Cole Pond   4AUG95 29 .23 30 .25 34 .47 32 .3
Eagle Lake  2JUN95 32 .35 32 .25 33 .30
Eagle Lake  3JUL95 30 .20 36 .45
Eagle Lake  4AUG95 33 .30 33 .28 34 .42
  ;
run;

proc transpose data=fishdata out=fishlength(rename=(col1=Measurement));
  var length1-length4;
  by location date;
run;

proc print data=fishlength noobs; run;
