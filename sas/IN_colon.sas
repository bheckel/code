options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: in_colon.sas
  *
  *  Summary: Wildcarding, mildly regex like.
  *
  *  Created: Mon 24 May 2004 16:07:33 (Bob Heckel)
  * Modified: Tue 25 May 2010 15:19:02 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source;

data tmp;
  set SASHELP.shoes;
  by region;
  /* Starts with A or E (case sensitive) */
  if region in:('A', 'E');
  if first.region;
/***  if region NOT in:('A', 'E');***/
run;

proc print data=tmp; run;
