options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: minmax_date.sas
  *
  *  Summary: Determine minimum and maximum dates
  *
  *  Created: Tue 28 Mar 2006 09:25:53 (Bob Heckel)
  * Modified: Tue 16 Oct 2012 08:39:57 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source NOcenter;

 /* Compare - can't use format here so get 19237 etc */
/***proc means data=t n min max;***/
/***  var test_date md;***/
/***run;***/

proc sql;
  select min(resentts) format=DATETIME19., max(resentts) format=DATETIME19.
  from l.sumvaltrex01a
  ;
quit;

proc sql;
  select min(_23034794_FILL_RM_HUM_PV) as min, max(_23034794_FILL_RM_HUM_PV) as max into :MIN, :MAX
  from l.ip21_0002t_line8filler
  ;
quit;
