options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: continue.sas
  *
  *  Summary: Demo of stopping the processing the current DO-loop iteration 
  *           and resuming with the next iteration.
  *
  *           See also leave.sas
  *
  *  Adapted: Mon 09 Jun 2003 14:17:17 (Bob Heckel --
  *                           file:///C:/bookshelf_sas/lgref/z0289377.htm)
  * Modified: Tue 08 Jan 2013 13:24:00 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source;

 /* Ignore the temporary serfs, report on fulltimers */
data new_emp;
   do i=1 to 4;
     input name $  idno  status $;
      /* Return to TOP OF LOOP when condition is true. */
      if status eq 'PT' then 
        continue;
      input benefits $10.;
      output;
   end;
  /* Fulltimers have two datalines per obs. */
  datalines;
Jones 100 PT
Thomas 200 PT
Richards 311 FT
Eye/Dental
Kelly 411 PT
Smith 511 FT
HMO
Foobar 611 FT
BAR
 ;
run;
proc print NOobs; run;

data new_emp;
   do i=1 to 4;
     input name $  idno  status $;
      if status eq 'PT' then 
        leave;  /* there are subtle differences */
      input benefits $10.;
      output;
   end;
  /* Fulltimers have two datalines per obs. */
  datalines;
Jones 100 PT
Thomas 200 PT
Richards 311 FT
Eye/Dental
Kelly 411 PT
Smith 511 FT
HMO
Foobar 611 FT
BAR
 ;
run;
proc print NOobs; run;
