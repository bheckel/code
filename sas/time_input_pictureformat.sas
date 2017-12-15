options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: time_input_pictureformat.sas
  *
  *  Summary: Demo of converting non-standard time values to SAS formatted 
  *           time values.
  *
  *  Adapted: Fri 02 May 2008 14:57:32 (Bob Heckel - combining_modifying.bksample.sas)
  *---------------------------------------------------------------------------
  */
options source NOcenter;

data time1;
  input timechar $11.;
  cards;
33.49
1:13.69
13:00:00.33
1:13:43.45
  ;
run;

proc format;
  picture TME other='99:99:99.99' ;
run;

data time2(drop=temp1 temp2);
  /*                         milliseconds */
  format sastimefmttd TIME11.2;
  set time1;

  temp1=compress(timechar, ':');

  /*        to numeric              */
  /*        ________________        */
  temp2=put(input(temp1,11.2), TME.);
  /*    _________________________   */
  /*        to char                 */

  /* Now temp2 looks like what SAS is expecting a time value to look like, 11
   * bytes wide, semicolons and period, etc.
   */
  put temp2=;
  sastimefmttd=input(temp2, TIME11.);
run;
proc print data=_LAST_(obs=max) width=minimum; run;
