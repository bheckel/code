options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: keep_only_highest_date_if_more_than_one.sas
  *
  *  Summary: Eliminate multiple records when we only want the highest one
  *
  *  Created: Wed 11 Nov 2015 14:06:09 (Bob Heckel -- https://stackoverflow.com/questions/3249236/how-to-find-max-value-of-variable-for-each-unique-observation-in-stacked-datas/32914780#32914780 user667489)
  * Modified: Thu 03 Nov 2016 14:58:25 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source NOcenter dsoptions=note2err;

data sample; 
  input id x; 
  datalines; 
18  1 
18  1 
18  2 
18  1 
18  2 
361 1 
369 2 
369 3 
369 3 
  ; 
run; 


proc sql;
  create table want as
  select id, max(x)
  from sample
  group by id;
quit;
title "&SYSDSN";proc print data=_LAST_(obs=10) width=minimum heading=H;run;title;


 /* Same but requires a sort */
proc sort data=sample; by id x; run;
data want;
  set sample;
  by id x;
put _all_;
  if last.id;
run;
title "ds:&SYSDSN";proc print data=_LAST_(obs=max) width=minimum heading=H; run;title;


 /* Faster - if id is sorted, x need not be: */
data want;
  do until(last.ID);
    set sample;
    by id;
    xmax = max(x, xmax);
  end;
  x = xmax;
  drop xmax;
run;
title "ds:&SYSDSN";proc print data=_LAST_(obs=max) width=minimum heading=H; run;title;


 /* Faster - nothing needs to be sorted: */
data _null_;
  set sample end=eof;
  if _n_ = 1 then do;
    call missing(xmax);
    declare hash h(ordered:'a');
    rc = h.definekey('ID');
    rc = h.definedata('ID','xmax');
    rc = h.definedone();
  end;
  rc = h.find();
  if rc = 0 then do;
    if x > xmax then do;
        xmax = x;
        rc = h.replace();
    end;
  end;
  else do;
    xmax = x;
    rc = h.add();
  end;

  if eof then rc = h.output(dataset:'want');
run;
title "ds:&SYSDSN";proc print data=_LAST_(obs=max) width=minimum heading=H; run;title;


 /* Slower - adds some overhead for unused calculations */
proc means data=sample noprint max nway missing; 
/***  class id;***/
  /* Better */
  by id;
  var x;
  output out=want(drop=_type_ _freq_) max=;
run;
title "ds:&SYSDSN";proc print data=_LAST_(obs=max) width=minimum heading=H; run;title;



endsas;
ds:WORK    WANT                            

Obs     id    x

 1      18    2
 2     361    1
 3     369    3
