options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: sql_soundex.sas
  *
  *  Summary: Demo of soundex near miss closest sounding match.
  *
  *  Created: Tue 07 Jun 2005 13:22:38 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source NOcenter;

proc sql;
  select * from SASHELP.shoes
  /* Want to use as many soundings as possible to get a match. */
  where Region =* 'arika' or Region =* 'affrica'
  ;
quit;
