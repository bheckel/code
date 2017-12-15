ods path reset;
ods path(prepend) work.styles(update);

proc template;
  define style styles.test;
    parent=styles.minimal;  /* inherit */
    style body from body / background=gray;
  end;
run;

ods excel file="~/bob/t.xlsx" style=styles.test;
proc print data=sashelp.class; run;
ods excel close;

proc template;
  delete styles.test;
run;
