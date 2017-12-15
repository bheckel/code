 /*---------------------------------------------------------------------------
  *     Name: single_trailing_at.sas
  *
  *  Summary: Demo of using a single '@' to hold a line and test it for a 
  *           condition.  If desired, you can keep it with a second INPUT line.
  *           Without the single at sign '@', SAS would automatically start
  *           reading the next line of raw data with each INPUT statement.
  *
  *           '@' is really a special case of the column pointer, @n  
  *
  *           Instead of telling SAS to move to a particular column, you tell
  *           it to "stay tuned for more information".  SAS will hold the line
  *           until it reaches either the end of the datastep or an INPUT
  *           statement that does not end with a trailing @.
  *
  *           Use a single trailing @ to allow the next INPUT statement to read
  *           from the same record. Use a double trailing @ to hold a record
  *           for the next INPUT statement across iterations of the DATA step.
  *
  *           A conditional input statement.
  *
  *           It is *not* needed if you're going to read all the vars in, then
  *           do calcs, etc. on all those vars.  In that case just add an "if
  *           foo ne 'bar' then delete;"
  *
  *  Adapted: Thu 11 Apr 2002 14:41:23 (Bob Heckel -- Little SAS Book sect 2.4)
  * Modified: Wed 06 Apr 2005 16:45:27 (Bob Heckel)
  *---------------------------------------------------------------------------
  */

* Use a single trailing @ to delete surface streets;
data freeways;
  infile datalines;
  input Type $  @;
  ***list;
  /* Hold on while I test Type. */
  if Type = 'surface' then delete;
  /* SAS will go to top of datastep (and this INPUT statement won't be seen)
   * only if surface is whacked. 
   */
  input Name $ 9-38  AMTraffic  PMTraffic;
  cards;
freeway 408                           3684 3459
surface Martin Luther King Jr. Blvd.  1590 1234
surface Rodeo Dr.                     1890 2067
freeway 608                           4583 3860
freeway 808                           2386 2518
surface Lake Shore Dr.                1590 1234
surface Pennsylvania Ave.             1259 1290
  ;
run;
proc print data = freeways;
  title 'Traffic for Freeways Only.  Work.freeways will not have any ';
  title2 'surface roads in it.';
run;
