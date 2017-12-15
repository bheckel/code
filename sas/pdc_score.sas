options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: pdc_score.sas
  *
  *  Summary: Compute proportion of days covered
  *
  *  Adapted: Thu 02 Jul 2015 10:54:07 (Bob Heckel -- www2.sas.com/proceedings/forum2007/043-2007.pdf)
  * Modified: Thu 29 Sep 2016 14:37:48 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source NOcenter dsoptions=note2err;

 /* A no overlapping days supply example */
data t;
  input member_id fill_dt MMDDYY10. drug $ days_supply;
  /* 2/17/2005 thru 8/15/2005 is 180 days inclusive, the study period so we want only obs in that range */
  /* Patient filled only 3 out of 6 times and the 3rd fell partially outside the study period end */
  cards;
603 02/17/2005 a 30  /* |2/17/05 to 3/18/05 (day 1-30)                                                                       |    */
603 06/13/2005 a 30  /* |                                 6/13/05 to 7/12/05 (day 117-146)                                   |    */
603 08/11/2005 a 30  /* |                                                                     8/11/05 to 9/9/05 (day 176-180)|    */
  ;
run;

proc sort; by member_id fill_dt; run;

 /*********************************/
 /* Make horizontal data vertical to a single obs per patient fills */

proc transpose data=t out=fill_dt prefix=fill_dt;
  by member_id;
  var fill_dt;
run;
proc print data=_LAST_(obs=max) width=minimum; run;
/*
       member_
Obs       id      _NAME_     fill_dt1    fill_dt2    fill_dt3

 1       603      fill_dt      16484       16600       16659 
*/ 


proc transpose data=t out=days_supply prefix=days_supply;
  by member_id;
  var days_supply;
run;
proc print data=_LAST_(obs=max) width=minimum; run;
/* 
       member_                    days_      days_      days_
Obs       id        _NAME_       supply1    supply2    supply3

 1       603      days_supply       30         30         30  
*/ 


data one_obs_per_patient;
  format start_dt end_dt fill_dt1-fill_dt3 MMDDYY10.;

  merge fill_dt days_supply;
  by member_id;

  start_dt = fill_dt1;
  end_dt = fill_dt1+179;
run;
proc print data=_LAST_(obs=max) width=minimum; run;
/* 
                                                                             member_                 days_      days_      days_
Obs     start_dt       end_dt       fill_dt1      fill_dt2      fill_dt3        id       _NAME_     supply1    supply2    supply3

 1     02/17/2005    08/15/2005    02/17/2005    06/13/2005    08/11/2005      603      days_sup       30         30         30  
*/
 /*********************************/


data pdc;
  set one_obs_per_patient;
  
  /* Create a patient-was-supplied flag variable for each day in the study period */
  array dayarray[180] day1-day180;
  /* Assume we have max of 11 fills incurred for a patient for the entire dataset */
  array filldates[*] fill_dt1-fill_dt11;
  array days_supply[*] days_supply1-days_supply11;

  /* i is a day, j is a fill */

  /* Initialize all patient-was-supplied flags */
  do i=1 to 180;
    dayarray[i]=0;
  end;

  /* For each day in the 180 day review period... */
  do i=1 to 180;
    put '!!! ' i=;
    /* If there was a fill in one of our 11 (but we have only 3 in this example) fills... */
    do j=1 to dim(filldates) while ( filldates[j] ne . );
      /* And if one of the 11 fills happened in our rolling days supplied window... */
      put '!!!! ' i= j= filldates[j]= days_supply[j]=;
      if filldates[j] <= start_dt+i-1 <= filldates[j]+days_supply[j]-1 then do;
        /* Then set a patient-was-supplied flag... */
        dayarray[i]=1;
      end;
    end;
  end;

  /* Fill1 30 + Fill2 30 + Fill3 8/11 thru 8/15 = 65 */
  dayscovered = sum(of day1-day180);
  /* PDC score */
  pct_days_covered = dayscovered/180;
run;
proc print data=_LAST_(obs=max) width=minimum; run;
/*
                                                                       d  d  d
                                                                       a  a  a
                                                                       y  y  y
                                                          m            s  s  s
      s                     f          f          f       e            _  _  _
      t                     i          i          i       m            s  s  s
      a          e          l          l          l       b     _      u  u  u
      r          n          l          l          l       e     N      p  p  p                   d d d d d d d d d d d d d d d d d d d d d d d d d d d d d d d d d d d d d d d d d d d d d d d d d d d d d d d d d d d d d d d d d d d d d d d d d d
      t          d          _          _          _       r     A      p  p  p d d d d d d d d d a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a
O     _          _          d          d          d       _     M      l  l  l a a a a a a a a a y y y y y y y y y y y y y y y y y y y y y y y y y y y y y y y y y y y y y y y y y y y y y y y y y y y y y y y y y y y y y y y y y y y y y y y y y y
b     d          d          t          t          t       i     E      y  y  y y y y y y y y y y 1 1 1 1 1 1 1 1 1 1 2 2 2 2 2 2 2 2 2 2 3 3 3 3 3 3 3 3 3 3 4 4 4 4 4 4 4 4 4 4 5 5 5 5 5 5 5 5 5 5 6 6 6 6 6 6 6 6 6 6 7 7 7 7 7 7 7 7 7 7 8 8 8 8
s     t          t          1          2          3       d     _      1  2  3 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3

1 02/17/2005 08/15/2005 02/17/2005 06/13/2005 08/11/2005 603 days_sup 30 30 30 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0

                                                                                                                                                                                                                                d d             p
                                                                                                                                                                                                                    d d d d d d a a             _
                                                                                                                                                                                                                    a a a a a a y y        d    d
                                                                                                                                                                                                                    y y y y y y s s        a    a
                                                                                                                                                                                                                f f s s s s s s _ _        y    y
                                                                                                                                                                                                    f f f f f f i i _ _ _ _ _ _ s s        s    s
                                                                                                                                                                                                    i i i i i i l l s s s s s s u u        c    c
                                  d d d d d d d d d d d d d d d d d d d d d d d d d d d d d d d d d d d d d d d d d d d d d d d d d d d d d d d d d d d d d d d d d d d d d d d d d d d d d d d d d l l l l l l l l u u u u u u p p        o    o
  d d d d d d d d d d d d d d d d a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a l l l l l l _ _ p p p p p p p p        v    v
  a a a a a a a a a a a a a a a a y y y y y y y y y y y y y y y y y y y y y y y y y y y y y y y y y y y y y y y y y y y y y y y y y y y y y y y y y y y y y y y y y y y y y y y y y y y y y y y y y _ _ _ _ _ _ d d p p p p p p l l        e    e
O y y y y y y y y y y y y y y y y 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 d d d d d d t t l l l l l l y y        r    r
b 8 8 8 8 8 8 9 9 9 9 9 9 9 9 9 9 0 0 0 0 0 0 0 0 0 0 1 1 1 1 1 1 1 1 1 1 2 2 2 2 2 2 2 2 2 2 3 3 3 3 3 3 3 3 3 3 4 4 4 4 4 4 4 4 4 4 5 5 5 5 5 5 5 5 5 5 6 6 6 6 6 6 6 6 6 6 7 7 7 7 7 7 7 7 7 7 8 t t t t t t 1 1 y y y y y y 1 1        e    e
s 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 4 5 6 7 8 9 0 1 4 5 6 7 8 9 0 1  j  i  d    d

1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 1 1 1 1 . . . . . . . . . . . . . . . . 181 4 65 0.36111
*/
*endsas;



 /* A crediting overlapping fills example */
data t;
  input member_id fill_dt MMDDYY10. drug $ days_supply;
  cards;
603 04/21/2005 a 30  /* |4/21/05 to 5/20/05 (day 1-30)                                                                 !                                 |  */
603 06/03/2005 a 30  /* |                                6/03/05 to 7/2/05 (day 44-73)                                 !                                 |  */
603 07/07/2005 a 30  /* |                                                                 7/07/05 to 8/5/05 (day 78-109)                                 |  */
603 07/30/2005 a 30  /* |                                                                                 7/30/05 to 8/2/05 (day 105-134)                |  */
  ;
                     /* |                                                           >>shift claim 3 to end of claim 2>> 8/6/05 to 9/4/05 (day 110-137)   |  */
run;

proc sql NOprint;
  select left(put(max(nfills),8.)) into :MAXNFILLS
  from (select count(*) as nfills from t group by member_id)
  ;
quit;
%put &=maxnfills;

proc sort; by member_id fill_dt; run;
title "ds:&SYSDSN";proc print data=_LAST_(obs=max) width=minimum heading=H; run;title;


 /* Transform from long to wide */

proc transpose data=t out=fill_dt prefix=fill_dt;
  by member_id;
  var fill_dt;
run;
proc print data=_LAST_(obs=max) width=minimum; run;

proc transpose data=t out=days_supply prefix=days_supply;
  by member_id;
  var days_supply;
run;
proc print data=_LAST_(obs=max) width=minimum; run;

data one_obs_per_patient;
  format start_dt end_dt fill_dt1-fill_dt4 MMDDYY10.;

  merge fill_dt days_supply;
  by member_id;

  start_dt = fill_dt1;
  /* This study runs for 180 days */
  end_dt = fill_dt1+179;
run;
proc print data=_LAST_(obs=max) width=minimum; run;


data pdc;
  set one_obs_per_patient;
  
  array dayarray[180] day1-day180;
  /* Assume we have max of 4 fills incurred for a patient for the entire dataset */
  array filldates[*] fill_dt1-fill_dt4;
  array days_supply[*] days_supply1-days_supply4;

  do i=1 to 180;
    dayarray[i]=0;
  end;

  do i=1 to 180;
    do j=1 to dim(filldates) while ( filldates[j] ne . );
      if filldates[j] <= start_dt+i-1 <= filldates[j]+days_supply[j]-1 then dayarray[i]=1;
    end;

    /**************************************************************************************************************/
    /* Shift any overlaps forward (starting with the 2nd fill) to day after the previous fill end to increase PDC */
    do k=2 to dim(filldates) while ( filldates[k] ne . );
      if filldates[k] < filldates[k-1]+days_supply[k-1] then do;
        put '!!!!! ' filldates[k]=;
        filldates[k] = filldates[k-1]+days_supply[k-1];
        put '!!!!!! ' filldates[k]=;
      end;
    end;
    /**************************************************************************************************************/
  end;

  /* 30 + 30 + 30 + (30 overlap 7/30 shifted out 7 days to 8/6) = 120 */
  dayscovered = sum(of day1-day180);
  /* PDC score */
  pct_days_covered = dayscovered/180;
run;
proc print data=_LAST_(obs=max) width=minimum; run;
