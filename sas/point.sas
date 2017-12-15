 /*---------------------------------------------------------------------------
  *     Name: point.sas
  *
  *  Summary: Demo of SET's POINT option.  POINT= specifies a temporary 
  *           *variable* whose numeric value determines which observation is
  *           read. POINT= causes the SET statement to use random (i.e. direct
  *           instead of the normal sequential) access to read a SAS data set. 
  *
  *           Do not use SET's END= when using POINT
  *
  *           Good for random subset sample sampling if ds is randomly ordered.
  *
  *           See also force_single_obs_dataset.sas
  *
  *  Created: Tue Jun 29 1999 16:08:47 (Bob Heckel)
  * Modified: Tue 25 May 2010 14:22:01 (Bob Heckel)
  *---------------------------------------------------------------------------
  */

data work.demo;
  infile cards missover;
  input idnum  name $  qtr1-qtr4;
  cards;
100 Taggart . . 14 18
200 Taggart . . 10 18
300 Taggart . . 10 19
400 Galt 22 14 6 28
500 Galt 23 15 7 29
  ;
run;

data foo;
  /* POINT= requires a var, not a literal number */
  obsnumiwant=2;  /* this assignment *must* happen prior to the SET */
  set demo point=obsnumiwant;
  output;  /* important */
  /* No EOF is detected in direct-access read mode. This STOP prevents the
   * data step from looping continuously.
   */
  stop;
run;
proc print data=_LAST_(obs=max); run;


/* Create new dataset using every other obs from the input ds. */
data work.tmp (keep= idnum qtr4);
  do oddobs=1 to totobz by 2;
    /* NOBS is number of obs in ds, assigned during compilation, by reading
     * dataset descriptor info
     */
    set work.demo point=oddobs NOBS=totobz;
    if _ERROR_ then
      abort;
    output;
  end;
  stop;
run;
title "&SYSDSN"; proc print; run; title;


 /* Get exactly 3 random obs */
data randomized;
  do i=1 to 3;
    obsnumiwant=ranuni(int(datetime()));
    set demo;
    output;
  end;
  stop;
run;
title "ds:&SYSDSN";proc print data=_LAST_(obs=max);run;


endsas;
From SUGI 179-2008
 /* Coding the read of a SAS data set within a DO loop is not just an intellectual
  * exercise to demonstrate the typical looping process in the DATA Step. It is
  * also the only way that a SAS data set can be read by specific observation,
  * which is done with the SET POINT= option.  The SET POINT option enables the SAS
  * program to move up or down a SAS data set according to the line number passed
  * to the Point variable, which is rowobs in this example.
  *
  * Note that the rowobs variable isn't in a RETAIN statement and yet its values
  * are still being retained during each pass through the DO loop! This is because
  * reading a Data Set in a DO loop prevents variables from being automatically
  * reset to blank or missing.
  */
data work2;
  readrow = 1;
  rowobs = 1;
  do while (readrow);
    If rowobs gt rowtot then
    readrow = 0;
  else
    do;
      /***********************************/
      set work1 nobs=rowtot POINT=rowobs;
      /***********************************/
      rowobs = rowobs + 1;
      output;
    end;
  end;
  stop;
run;
