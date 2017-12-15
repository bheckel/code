options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: intck.sas
  *
  *  Summary: Calculate the interval between two dates.
  *
  *           'C' Continuous interval is shifted based on the starting date (e.g. age)
  *           'D' Discrete interval boundaries (e.g. end of month).
  *
  *  Created: Mon 05 May 2003 12:15:54 (Bob Heckel)
  * Modified: Mon 29 Feb 2016 16:21:36 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source;

data _NULL_;
  /* DISCrete intervals are counted from fixed beginnings.  YEAR is counted from 01Jan, WEEK is counted from Sunday: */
  /*
      December 2000   
      Su Mo Tu We Th Fr Sa
                      1  2
       3  4  5  6  7  8  9
       10 11 12 13 14 15 16
       17 18 19 20 21 22 23
       24 25 26 27 28 29 30
       31

       January 2001    
       Su Mo Tu We Th Fr Sa
           1  2  3  4  5  6
        7  8  9 10 11 12 13
        14 15 16 17 18 19 20
        21 22 23 24 25 26 27
        28 29 30 31

  */
  /* 'D' DISC is default if omitted */
/***  wks = intck('WEEK', '31dec2000'D, '01jan2001'D, 'DISC');***/
  wks = intck('WEEK', '31dec2000'D, '01jan2001'D);
  wks2 = intck('WEEK', '31dec2000'D, '13jan2001'D);
  wks3 = intck('WEEK', '31dec2000'D, '15jan2001'D);
  wks4 = intck('WEEK', '25dec2000'D, '02jan2001'D);
  put wks= wks2= wks3= wks4=;

  yr = intck('YEAR', '01jan2000'D, '31dec2000'D);  /* YEAR boundary not crossed so 0 */
  yr2 = intck('YEAR', '01jan2000'D, '01jan2001'D); /* 1 */
  put yr= yr2=;

  agethisyear = intck('YEAR', '30oct1965'D, '01jan2016'D, 'DISC');
  /* same */
/***  agethisyear = intck('YEAR', '30oct1965'D, '31jan2016'D, 'DISC');***/
  put agethisyear=;

  agetoday = intck('YEAR', '30oct1965'D, '01jan2016'D, 'CONT');
  put agetoday=;

  days=intck('DTDAY', '01dec2000:00:10:48'dt, '01jan2001:00:10:48'dt);
  put days=;
run;



endsas;
/***  sixmonthsago = '01JUN08'd - 180;***/
  sixmonthsago = "&SYSDATE"d - 180;
  put sixmonthsago DATE9.;

