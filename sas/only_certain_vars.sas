options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: only_certain_vars.sas
  *
  *  Summary: If get out of memory error, use this to limit the vars
  *           displayed.
  *
  *  Created: Mon 26 Jul 2004 15:24:25 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source NOcenter;

options NOcenter;
libname IN 'DWJ2.NAT2003.MVDS.LIBRARY.NEW';             

proc sql NOPRINT;
  select name into :VARS separated by ' '
  from dictionary.columns
  /* Case sensitive! */
  where libname eq 'IN' and memname eq 'PANEW' and name like 'A%'
  order by name
  ;
quit;

proc print data=IN.PANEW; 
  var &VARS;
run;
