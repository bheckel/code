
cas sessopts=(caslib=casuser timeout=1800 locale="en_US");  /* session default is casauto if this line isn't submitted */
 /* or */
/* cas mySession sessopts=(caslib=casuser timeout=1800 locale="en_US"); */

 /* don't need?? */
cas;

%put Active caslib=%sysfunc(GETSESSOPT(casauto, caslib));
 /* Active caslib=CASUSER(bheck) */

 /* Make the Public caslib the active caslib */
cas sessopts=(caslib=public timeout=1800 locale="en_US");

 /* Show e.g. Path = /casuserlibraries/bheck/ */
caslib casuser(boheck) list;


 /* Show e.g. Path = /opt/sas/viya/config/data/cas/default/public/ */
caslib public list;

 /* Show .sashdat files */
proc casutil; list files incaslib="public"; quit;

 /* Return to CASUSER */
cas sessopts=(caslib=casuser timeout=1800 locale="en_US");
proc casutil; list files /*incaslib="casuser"*/; quit;  /* default is active caslib */

cas terminate;  /* the session */

---

libname atlas cas caslib="MKC - Atlas (DNFS)" datalimit=ALL; proc print data=atlas.diball(obs=10);run;

