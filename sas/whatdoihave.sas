options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: whatdoihave.sas
  *
  *  Summary: Determine current system's configuration.
  *
  *  Adapted: Fri 20 Jun 2003 22:35:38 (Bob Heckel -- SAS Tips Newsletter)
  *---------------------------------------------------------------------------
  */
options source;


libname  _all_  list;

filename  _all_  list;

proc setinit; run;

 /* Include undocumented. */
proc options internal; run ;

proc template;
  list styles;
run;
