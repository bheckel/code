data _null_;
  do year=2006 to 2011;
    fdoy=mdy(1,1,year);
    /* For years prior to 2007, daylight time begins in the United States on */
    /* the first Sunday in April and ends on the last Sunday in October.     */
    if year <= 2006 then do;
      fdo_apr=intnx('month',fdoy,3);
      dst_beg=intnx('week.1',fdo_apr,(weekday(fdo_apr) ne 1));
      fdo_oct=intnx('month',fdoy,9);
      dst_end=intnx('week.1',fdo_oct,(weekday(fdo_oct) in (6,7))+4);
    end;

    /* Due to the Energy Policy Act of 2005, Pub. L. no. 109-58, 119 Stat 594 */
    /* (2005).  Starting in March 2007, daylight time in the United States    */
    /* will begin on the second Sunday in March and end on the first Sunday   */
    /* in November.  For more information, one reference is                   */
    /* http://aa.usno.navy.mil                                                */
    else do;  
      fdo_mar=intnx('month',fdoy,2);
      dst_beg=intnx('week.1',fdo_mar, (weekday(fdo_mar) in (2,3,4,5,6,7))+1);
      fdo_nov=intnx('month',fdoy,10);
      dst_end=intnx('week.1',fdo_nov,(weekday(fdo_nov) ne 1));
    end;
    put dst_beg= worddate. /
    dst_end= worddate. / ;
  end;
run;
