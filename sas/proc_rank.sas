
/* Postgres: SELECT depname, empno, salary, rank() OVER (PARTITION BY depname ORDER BY salary DESC) FROM empsalary; */

proc sort data=sashelp.class out=class; by height age; run;

proc rank data=class out=t ties=dense;
  var height age;
  ranks heightrank agerank;  /* overwrites existing vars if not specified here */
run;
proc print data=_LAST_ width=minimum heading=H;run;



proc rank data=class groups=100 out=percentile_rank;
  var height;
  ranks rank_x;
run;
title "&SYSDSN";proc print data=_LAST_ width=minimum heading=H;run;title;

proc rank data=class groups=4 out=quartile_rank;
  var height;
  ranks rank_x;
run;
title "&SYSDSN";proc print data=_LAST_ width=minimum heading=H;run;title;
