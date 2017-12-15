data t;
  input x $20.;
cards;
2007-10-13T20:04:00  isdst
2009-10-13T20:06:00  isdst
2010-02-23T10:06:00  isnotdst
2010-08-23T10:06:00  isdst
;
run;

data t2;
  set t;
  thisyr = year(date());
  y = input(x, IS8601DT.);
  d = datepart(y);

  do yr=2000 to thisyr;
    fdoy = mdy(1,1,yr);
    /* <2007, daylight time begins in the United States on the first Sunday in April and ends on the last Sunday in October */
    if yr <= 2006 then do;
      fdo_apr=intnx('month',fdoy,3);
      dst_beg=intnx('week.1',fdo_apr,(weekday(fdo_apr) ne 1));
      fdo_oct=intnx('month',fdoy,9);
      dst_end=intnx('week.1',fdo_oct,(weekday(fdo_oct) in (6,7))+4);
    end;
    /*  =>2007, daylight time in the United States will begin on the second Sunday in March and end on the first Sunday in November */
    else do;  
      fdo_mar=intnx('month',fdoy,2);
      dst_beg=intnx('week.1',fdo_mar, (weekday(fdo_mar) in (2,3,4,5,6,7))+1);
      fdo_nov=intnx('month',fdoy,10);
      dst_end=intnx('week.1',fdo_nov,(weekday(fdo_nov) ne 1));
    end;

    if year(d) eq yr then do;
      if (d >= dst_beg) and (d < dst_end) then do;
        dst=-4;
        z=put(y+(dst*60*60), IS8601DT.);
      end;
      else do;
        dst=-5;
        z=put(y+(dst*60*60), IS8601DT.);
      end;
      put dst_beg= WORDDATE. dst_end= WORDDATE. z= dst=;
    end;
  end;
run;
proc print data=_LAST_(obs=max) width=minimum; ; run;
