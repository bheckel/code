
 /* SAS "helpfully" interprets this syntax error and keeps going after WARNING (compiles and executes) */
proc print data=sashelp.shoes(obs=1) idth=minimum; run;
 /* This syntax ERROR: stops SAS - for this Program Step (compiles but does not execute) */
proc print data=sashelp.shoes(obs=2) izth=minimum; run;
 /* ...but then it keeps going and runs this successfully (compiles and execute) */
proc print data=sashelp.shoes(obs=3) width=minimum; run;

