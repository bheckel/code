/*----------------------------------------------------------------------------
 * Program Name: timeduration.sas
 *
 *      Summary: Read in some raw date and time values and process them. 
 *               Portions Copyright (C) 1999 by SAS Institute Inc., Cary, NC, 
 *               USA. 
 *      Adapted: Mon Jun 07 1999 15:37:25 (Bob Heckel)
 * Modified: Wed 23 Jun 2010 15:26:09 (Bob Heckel)
 *----------------------------------------------------------------------------
 */

data work.tktdata;
  input @001 tkt       $CHAR08.
        @010 dateopen  MMDDYY8.
        @020 timeopen  TIME5.
        @030 dateclos  MMDDYY8.
        @040 timeclos  TIME5.
        @050 duration  $CHAR10.;
/*--+----1----+----2----+----3----+----4----+----5----+----6---*/
  cards;
0862     01/02/60  19:30     05/04/98   23:40     0000:04:10
0863     05/04/98  18:52     05/06/98    0:09     -000:18:43
0867     05/12/98  15:49     05/13/98    0:58     -000:14:51
0869     05/16/98  19:18     05/27/98   20_00     0000:00:42
0883     06/13/98   4:00     06/14/98   08:10     0001:04:10
0883     06/13/98   4:00     06/13/98   08:10     0000:04:10
0883     06/13/98   4:39     06/12/98   15:44     0004:05:53
11111111106/20/98  17:20     06/18/98   17:45     0000:00:39
11111111106/20/98  17:10     06/20/98   17 20     0000:00:10
  ;
run;
proc print; run;


data work.tktdata; 
  set work.tktdata;
  /* Return a SAS datetime value. */
  /*              Date        Hour           Minute         Second
  opened = DHMS(dateopen, hour(timeopen), minute(timeopen), 0);
  closed = DHMS(dateclos, hour(timeclos), minute(timeclos), 0);

  /* Seconds. */
  pdur   = closed - opened;
  pdays  = int(pdur/(60*60*24));
  prest  = mod(pdur,(60*60*24));

  /* This will handle time that is negative to get minutes want the minutes
   * but not negative time here. 
   */
  if prest < 0 then 
    do;
      ph   = hour(prest * -1);
      pm   = minute(prest * -1);
    end;
  else 
    do;
      ph   = hour(prest);
      pm   = minute(prest);
    end;

  pdays2 = put(pdays,Z4.);
  ph2    = put(ph,Z2.);
  pm2    = put(pm,Z2.);

  /* If negative tack on a - sign.  If negative days the minus is already
   * there 
   */
  if pdays > 0 or pdays <= -1 then
    probdur = pdays2||':'||ph2||':'||pm2;
  else if pdays =0 and prest > 0 then
    probdur = '0000:'||ph2||':'||pm2 ;
  else
    probdur = '-000:'||ph2||':'||pm2 ;
run;

proc sort data=work.tktdata;
  by tkt;
run;

proc print data=work.tktdata noobs uniform split='*' n ;
  format dateopen dateclos MMDDYY8. timeopen timeclos time5.;
  title 'Duration calculated as pdur and probdur';
  var tkt dateopen timeopen dateclos timeclos duration pdur probdur;
run;
