 /* From my class notes handout */

ods path show;

proc template;
  ***list styles / store=SASHELP.tmplmst;
  /* same */
  list styles;
run;
