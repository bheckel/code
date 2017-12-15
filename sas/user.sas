 /* If default WORK lib is too small we'll use this as WORK storage. 
  * TEMP and DSTEMP are arbitrary.
  * A cylinder on CDC mf is about a megabyte.
  *
  * WORK is not deleted at end of job when running under batch (overrides
  * normal behavior).
  *
  * Be careful if qualifying datasets with 'WORK.' probably will break.
  */

options notes source;

***libname TEMPWRK '&DSTEMP' space=(cyl,(1000,1000));
libname TEMPWRK 'BQH0.TEMP.SASLIB';  /* this one doesn't autodelete the ds */
options USER=TEMPWRK;

data tmp;
  set SASHELP.shoes;
run;
proc print data=_LAST_; run;
