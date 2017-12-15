options nosource;
 /*---------------------------------------------------------------------------
  *     Name: xport.sas
  *
  *  Summary: Demo of transporting datasets across platforms.
  *
  *  Adapted: Tue 07 Jan 2003 16:06:59 (Bob Heckel -- p. 491 Professional
  *                                     SAS Shortcuts Rick Aster)
  * Modified: Thu 15 Nov 2012 15:24:44 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source replace;

data WORK.sample;
  /* PROC COPY below will fail if vars are >8 char */
  input fname $1-10  lname $15-25  @30 numb 3.;
  datalines;
mario         lemieux        123
ron           francis        123
  ;
run;


libname XP xport 'c:/TEMP/foo.xpt';  /* file masquerading as a directory! */

proc copy in=WORK out=XP;
  select sample;
run;
