 /* Fix the reviser file dataset used by FCAST #6.6 */

options NOcenter;
libname L "DWJ2.MOR2005.LAST.REVISER.FILE";
***libname L 'DWJ2.FET2005.LAST.REVISER.MERGED.FILE';  /* fet only wtf? */

title 'before';
proc print data=L.data(obs=max); run;

data L.data;
  set L.data end=e;
  output;
  if e then
    do;
      /* Add a record */
      date_update=datetime();
      mergefile='BF19.WAX05000.MORMERZ';
      stabbrev='WA';
      userid='bqh0';
      output;
    end;
run;

proc sort data=L.data;
  by stabbrev;
run;

title 'after';
proc print data=_LAST_(obs=max); run;
