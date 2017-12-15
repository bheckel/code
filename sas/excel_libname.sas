/* See read_write_excel.sas */
/* TODO not working on Win7 with 32 bit Office */

libname lx PCFILES  PATH='Book1.xls';

data t;
  set lx.'my Sheet1$'n;
run;
proc datasets library=lx;run;

/***proc print data=_LAST_(obs=max) width=minimum; run;***/


endsas;
 /* v9+ */
libname lx excel 'c:/temp/Zebulon_zebadvairgenealogy.xls' mixed=yes;

data t;
  set lx.'zebulon_zebadvairgenealogy$'n;
run;
