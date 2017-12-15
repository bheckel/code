options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: input_function.sas
  *
  *  Summary: Convert badly (messy) incoming formatted data.
  *
  *           This is NOT to be confused with the input STATEMENT!  It can't
  *           read past the end of the character value.
  *
  *  Created: Tue 08 Jun 2004 15:17:37 (Bob Heckel)
  * Modified: Mon 06 Apr 2015 15:47:57 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source;

data baddata;
  baddate = '19651030';
  baddollars = '$123,456.78';
  badtime = '01:00';
  anum = 1234;
  anum2 = 'wtf';
run;

data gooddata;
  set baddata;

  /* Char is now num */
  gooddate = input(baddate, YYMMDD8.);  /* days since 1960 */
  /* Char is now num */
  goodamt = input(baddollars, DOLLAR13.2);  /* store w/o '$' and ',' */
  /* Char is now num */
  goodtime = input(badtime, TIME5.);  /* seconds since midnight */

  /* Left align */
  x = input(anum, BEST. -L);
/***  y = input(anum2, BEST. -L);***/
  /* Better if you expect dirty data */
  y = input(anum2, ? BEST. -L);  /* suppress Log "NOTE: Invalid argument to function INPUT at line..." */
run;
proc print data=_LAST_; run;
