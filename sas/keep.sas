
 /* Similar examples work for DROP */

data t;
  set sashelp.shoes;
  keep stores;
run;

proc print data=_LAST_(obs=10); run;

 /* Even works for PROCs but must be dataset option-style, not statement-style */
proc print data=sashelp.shoes(keep=region s: obs=10); run;
