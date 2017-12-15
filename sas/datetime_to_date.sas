options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: datetime_to_date.sas
  *
  *  Summary: Convert breakout from datetime value to date and time components
  *
  *  Created: Mon 02 Oct 2006 10:03:14 (Bob Heckel)
  * Modified: Wed 11 Jun 2008 09:30:14 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source NOcenter;

data tmp;
  fulldt='31dec60:0:05'DT;

  put fulldt=;

  /* Convert SAS datetime (10 digit wide seconds since epoch) to SAS numeric
   * date (5 digit wide days since epoch)
   */
  d=datepart(fulldt);

  /* 300 seconds into dec 31 */
  t=timepart(fulldt);

  /* Now reformat date for humans.  f is CHAR.  Must be a new var, can't
   * recycle fulldt 
   */
  f=put(datepart(fulldt), DATE9.);

  put _all_;
run;

proc print data=tmp; format d DATE8.; run;

proc contents data=tmp; run; 
