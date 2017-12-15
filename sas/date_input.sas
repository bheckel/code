options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: date_input.sas
  *
  *  Summary: Input calendar date data into a dataset and store as SAS date.
  *
  *           Simple:
  *           Read 06/01/15 in as @1 dlu $8. then
  *             dlu = input(TMPdlu, MMDDYY8.);
  *             format dlu DATE9.;
  *
  *  Created: Wed 11 Feb 2004 11:18:50 (Bob Heckel)
  * Modified: Mon 29 Jun 2015 10:22:05 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source;

data tmp;
  /* Date's delimiter, if any, doesn't matter!  MMDDYY10. magically reads in
   * all of them
   */
  input id $4.  @6 paydt1 MMDDYY10.  @17 paydt2 MMDDYY10.  @30 gskdate DATE9.;
  cards;
QDSW 04/15/2002 06/15/2002   15-Nov-08
jhh  5-2-02     8-1-2002     10-Nov-08
mpwz 12012002   03042003      1-Jan-60
  ;
run;
 /* Stored in numeric days since the epoch unless we override with a format */
proc print; 
  format paydt1 MMDDYY10.;
run;



 /* Assuming we read in datetime in as a single string: */
data freeweigh;
  input dtDateTimeCH $80.;
  cards;
4/28/2008 2:17:53 AM
4/25/2008 4:26:30 PM
  ;
run;
proc print data=_LAST_(obs=max) width=minimum; run;

 /* Convert strings to SAS dates and times */
data freeweigh;
  set freeweigh;

  /* Save date and time each in a native SAS format */
  dtDate = scan(dtDateTimeCH, 1, ' ');
  len = length(dtDate);
  dtDate = input(dtDate, MMDDYY10.);
  dtTime = substr(dtDateTimeCH, len+1);
  dtTime = input(dtTime, TIME11.);  /* handle the AM PM crap */

  /* or better, save as a single native SAS datetime */
  dtval = dhms(dtDate, 0, 0, dtTime);
  put _all_;
run;
proc print data=_LAST_(obs=max) width=minimum; 
  ***format dtval DATETIME16.; 
run;



 /* Handle varying date formats */
data datevaries;
  input dtDateTimeCH $11.;
  cards;
05/21/1998
21-May-1998
07-Jul-2000
07/07/2000
Jul:31:2008
10/30/1965
  ;
run;

data t;
  set datevaries;
  /* Input is sometimes 5/1/2008 other times 01-May-2008 */
  if index(dtDateTimeCH, '/') then
    dtDate = input(dtDateTimeCH, MMDDYY10.);
  else if index(dtDateTimeCH, '-') then
    dtDate = input(dtDateTimeCH, DATE11.);
  else
    put 'WARNING: dtDateTimeCH is not formatted as expected: ' dtDateTimeCH=;
run;
proc print data=_LAST_(obs=max) width=minimum; run;
