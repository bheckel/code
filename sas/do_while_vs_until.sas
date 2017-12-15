options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: do_while_vs_until.sas
  *
  *  Summary: Comparison of do while vs. do until loops.
  *
  *  Adapted: Wed 04 Jun 2003 13:16:22 (Bob Heckel --
  *                            file:///C:/bookshelf_sas/lgref/z0201924.htm)
  * Modified: Thu 01 Apr 2004 11:11:34 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source;

 /* Evaluate at top of loop. */
data _NULL_;
  w = 0;
  do while ( w<5 );
    put w=;
    w + 1;
  end;
run;

 /* Evaluate at bottom of loop.  Guaranteed to execute AT LEAST ONCE. */
data _NULL_;
  u = 0;
  do until ( u>5 );
    put u=;
    u + 1;
  end;
run;


 /* More complicated variation on do until / while loop: */
data work.invest2;
  ***do y=1990 to 2004 until ( capital > 300 );
  /* Same */
  do y=1990 to 2004  while ( capital < 300 );  /* loop iterates 15 times as long as capital stays < 300 */
    ***capital = capital + 10;
    /* Same */
    capital+10;
    capital + (capital * 0.10);
    output;
  end;
run;
proc print; run;
